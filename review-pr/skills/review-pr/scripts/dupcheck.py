#!/usr/bin/env python3
"""두 코드 조각의 유사도를 잰다. review-pr 스킬 5단계(중복 코드)의 측정 도구.

사용법:
  python3 dupcheck.py A.txt B.txt                  # 수치만
  python3 dupcheck.py A.txt B.txt --html          # 보고서 .compare 블록용 figure 두 개 + measure 한 줄
  python3 dupcheck.py A.txt B.txt --label-a "파일:줄 이름A" --label-b "파일:줄 이름B" --html
  python3 dupcheck.py --file path.py:10-40 --file other.py:5-30   # 파일의 줄 범위를 조각으로 읽는다

측정 규칙(스킬 용어표 "유사도"):
- SequenceMatcher(None, a, b, autojunk=False). 기본값 autojunk=True 는 200자 넘는 조각에서 자주 나오는 글자를
  junk 로 버려 유사도를 낮게 잰다(실측: 같은 쌍이 0.569 → 0.705).
- 정규화: 줄마다 앞뒤 공백 제거, 빈 줄 제거, 줄 끝 주석(# …, // …) 제거. 식별자·리터럴은 바꾸지 않는다.
- 최장 공통 구간은 정규화한 텍스트 기준 글자 수다.
"""
from __future__ import annotations

import argparse
import difflib
import html
import re
import sys
from pathlib import Path

_COMMENT = re.compile(r"\s+(#|//)[^\n]*$")


def normalize(text: str) -> str:
    lines = []
    for raw in text.splitlines():
        line = _COMMENT.sub("", raw).strip()
        if line:
            lines.append(line)
    return "\n".join(lines)


def read_fragment(spec: str) -> str:
    """'path' 또는 'path:START-END'(1-based, 양끝 포함)."""
    m = re.match(r"^(.*?):(\d+)-(\d+)$", spec)
    if m:
        path, start, end = Path(m.group(1)), int(m.group(2)), int(m.group(3))
        lines = path.read_text(encoding="utf-8").splitlines()
        return "\n".join(lines[start - 1 : end])
    return Path(spec).read_text(encoding="utf-8")


def measure(a: str, b: str) -> tuple[float, int, str, int, int]:
    na, nb = normalize(a), normalize(b)
    sm = difflib.SequenceMatcher(None, na, nb, autojunk=False)
    m = sm.find_longest_match(0, len(na), 0, len(nb))
    return sm.ratio(), m.size, na[m.a : m.a + m.size], m.a, m.b


def band(ratio: float) -> str:
    if ratio >= 0.9:
        return "복사본"
    if ratio >= 0.6:
        return "부분 공유"
    return "중복 아님"


def mark(text: str, start: int, size: int) -> str:
    return (
        html.escape(text[:start])
        + "<mark>"
        + html.escape(text[start : start + size])
        + "</mark>"
        + html.escape(text[start + size :])
    )


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("a", nargs="?", help="조각 A 파일")
    p.add_argument("b", nargs="?", help="조각 B 파일")
    p.add_argument("--file", action="append", default=[], help="path:START-END 형식의 조각. 두 번 준다")
    p.add_argument("--label-a", default="조각 A")
    p.add_argument("--label-b", default="조각 B")
    p.add_argument("--html", action="store_true", help=".compare 블록 HTML 을 낸다")
    args = p.parse_args()

    specs = args.file or [args.a, args.b]
    if len(specs) != 2 or not all(specs):
        p.error("조각 두 개가 필요하다: A B 또는 --file 두 번")
    a, b = read_fragment(specs[0]), read_fragment(specs[1])
    if args.file:
        args.label_a = args.label_a if args.label_a != "조각 A" else specs[0]
        args.label_b = args.label_b if args.label_b != "조각 B" else specs[1]

    ratio, size, common, ia, ib = measure(a, b)
    na, nb = normalize(a), normalize(b)
    summary = f"difflib ratio {ratio:.3f}(autojunk=False) · 최장 공통 구간 {size}자 · {band(ratio)} · 공백·빈 줄·줄 끝 주석 정규화"

    if not args.html:
        print(summary)
        print(f"A {len(na)}자 · B {len(nb)}자")
        print("최장 공통 구간:")
        print(common)
        return 0

    print('<div class="compare">')
    print(f"  <figure><figcaption><code>{html.escape(args.label_a)}</code></figcaption><pre><code>{mark(na, ia, size)}</code></pre></figure>")
    print(f"  <figure><figcaption><code>{html.escape(args.label_b)}</code></figcaption><pre><code>{mark(nb, ib, size)}</code></pre></figure>")
    print("</div>")
    print(f'<p class="measure">{html.escape(summary)}</p>')
    return 0


if __name__ == "__main__":
    sys.exit(main())
