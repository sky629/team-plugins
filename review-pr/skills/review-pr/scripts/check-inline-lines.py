#!/usr/bin/env python3
"""인라인 코멘트의 줄 번호가 PR diff hunk 안에 있는지 검사한다. review-pr 스킬 10단계.

사용법:
  gh pr diff N | python3 check-inline-lines.py prN-review.json
  python3 check-inline-lines.py prN-review.json prN.diff

규칙: GitHub 리뷰 POST 는 comments[] 의 path·line(·start_line) 이 하나라도 diff hunk 밖이면 전체가 422 로 실패한다.
side 는 RIGHT(PR head) 기준이다. 종료 코드: 0 전부 안 · 1 하나라도 밖.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

_FILE = re.compile(r"^\+\+\+ b/(.+)$")
_HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")


def hunks_by_path(diff_text: str) -> dict[str, list[tuple[int, int]]]:
    out: dict[str, list[tuple[int, int]]] = {}
    path = None
    for line in diff_text.splitlines():
        m = _FILE.match(line)
        if m:
            path = m.group(1)
            out.setdefault(path, [])
            continue
        m = _HUNK.match(line)
        if m and path is not None:
            start = int(m.group(1))
            count = int(m.group(2)) if m.group(2) is not None else 1
            out[path].append((start, start + count - 1))
    return out


def inside(line: int, ranges: list[tuple[int, int]]) -> bool:
    return any(a <= line <= b for a, b in ranges)


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    payload = json.loads(Path(argv[0]).read_text(encoding="utf-8"))
    diff_text = Path(argv[1]).read_text(encoding="utf-8") if len(argv) > 1 else sys.stdin.read()
    hunks = hunks_by_path(diff_text)
    comments = payload.get("comments", [])
    bad = 0
    for i, c in enumerate(comments, 1):
        path, line = c.get("path"), c.get("line")
        start = c.get("start_line")
        ranges = hunks.get(path)
        if ranges is None:
            print(f"FAIL #{i} {path}: diff 에 없는 파일")
            bad += 1
            continue
        for label, n in (("line", line), ("start_line", start)):
            if n is None:
                continue
            if not inside(int(n), ranges):
                print(f"FAIL #{i} {path}:{n} ({label}) hunk 밖. hunk={ranges}")
                bad += 1
    print(f"인라인 {len(comments)}개 · hunk 밖 {bad}개 · 결과: {'실패' if bad else '통과'}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
