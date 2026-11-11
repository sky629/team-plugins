#!/usr/bin/env bash
# diagram-design HTML 의 <svg> 영역만 PNG 로 추출한다(ego-browser 사용).
# 제목·eyebrow 는 빼고 그림만 담는다. 노션 본문에서는 헤딩이 제목 역할을 한다.
#
# 사용법:  export_png.sh <diagram.html> [out.png] [width-px]
#   out.png 미지정 시 HTML 과 같은 자리에 같은 이름의 .png 로 저장한다.
#   width-px 는 PNG 의 가로 픽셀 수이며 기본값은 2400 이다.
set -euo pipefail

[ $# -ge 1 ] || { echo "사용법: export_png.sh <diagram.html> [out.png] [width-px]" >&2; exit 2; }
[ -f "$1" ] || { echo "ERROR: HTML 파일이 없습니다: $1" >&2; exit 1; }

HTML="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUT="${2:-${HTML%.html}.png}"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac
WIDTH="${3:-2400}"

# ego-browser 스크립트는 셸 환경 변수를 물려받지 않으므로, 입력값을 JSON 리터럴로 스크립트에 직접 넣는다.
ARGS="$(python3 -c 'import json,sys; print(json.dumps({"html": sys.argv[1], "out": sys.argv[2], "width": int(sys.argv[3])}))' "$HTML" "$OUT" "$WIDTH")"

ego-browser nodejs <<EOF
const args = $ARGS;
const fs = await import("node:fs/promises");
const { pathToFileURL } = await import("node:url");
const task = await taskSpace("make_notion png export");
const page = task.page("p1");
await page.goto(pathToFileURL(args.html).href);
await page.waitForSelector("svg", { state: "visible" });
await page.evaluate(() => document.fonts.ready.then(() => true));
const box = await page.evaluate(() => {
  const r = document.querySelector("svg").getBoundingClientRect();
  return { x: r.left + window.scrollX, y: r.top + window.scrollY, width: r.width, height: r.height, dpr: window.devicePixelRatio };
});
const { dpr, ...clip } = box;
// clip.scale 은 기기 픽셀 비율 위에 곱해지므로, 창 크기·화면 종류와 무관하게 가로 픽셀 수가 고정되도록 나눈다.
const shot = await page.cdp("Page.captureScreenshot", {
  format: "png",
  captureBeyondViewport: true,
  clip: { ...clip, scale: args.width / (clip.width * dpr) },
});
await fs.writeFile(args.out, Buffer.from(shot.data, "base64"));
await task.finish({ keep: [] });
console.log(args.out);
EOF
