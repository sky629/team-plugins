#!/usr/bin/env python3
"""리뷰 산출물의 기계 점검. review-pr 스킬 9·10단계.

사용법:
  python3 check-report.py prN-review.html [prN-comments.md prN-review.json prN-link-comment.md ...]

검사:
  1. HTML 에 남은 템플릿 주석(<!-- -->)과 자리표시자(NNNN, <주제>, YYYY-MM-DD, "0/0", 사다리 "n/5"·"사다리 n", 변이 "m개(항목 ID)").  → 하나라도 있으면 실패
  2. 모든 입력의 본문(태그를 벗긴 텍스트, JSON 은 문자열 값)에서 추측 표현이 든 문장을 전부 출력한다.
     패턴: 수 있|예상|보인다|추정|아마|가능성|것이다|듯하다|것으로
     이 목록은 사람이 문장마다 읽는다. 결과 주장이면 지우거나 확인한 사실로 바꾼다. 기능 설명이면 남긴다.
     --strict 를 주면 한 문장이라도 있으면 실패.
종료 코드: 0 통과 · 1 실패.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

PLACEHOLDERS = ["NNNN", "<주제>", "YYYY-MM-DD", "&lt;base sha&gt;", "&lt;head sha&gt;", "n/5", "사다리 n", "m개(항목 ID)"]
SPECULATION = re.compile(r"(수 있|예상|보인다|추정|아마|가능성|것이다|듯하다|것으로)")
_TAG = re.compile(r"<[^>]+>")
_SENT = re.compile(r"(?<=[.。!?])\s+|\n+")


def strip_tags(html_text: str) -> str:
    text = re.sub(r"<(script|style)\b.*?</\1>", " ", html_text, flags=re.S | re.I)
    text = _TAG.sub(" ", text)
    return re.sub(r"[ \t]+", " ", text)


def json_strings(obj) -> list[str]:
    out: list[str] = []
    if isinstance(obj, str):
        out.append(obj)
    elif isinstance(obj, dict):
        for v in obj.values():
            out.extend(json_strings(v))
    elif isinstance(obj, list):
        for v in obj:
            out.extend(json_strings(v))
    return out


def body_text(path: Path) -> str:
    raw = path.read_text(encoding="utf-8")
    if path.suffix == ".html":
        return strip_tags(raw)
    if path.suffix == ".json":
        return "\n".join(json_strings(json.loads(raw)))
    return raw


def check_html(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    problems: list[str] = []
    for i, line in enumerate(raw.splitlines(), 1):
        if "<!--" in line:
            problems.append(f"{path.name}:{i} 템플릿 주석 남음: {line.strip()[:100]}")
        for ph in PLACEHOLDERS:
            if ph in line:
                problems.append(f"{path.name}:{i} 자리표시자 남음: {ph}")
    tiles = re.findall(r'<span class="n[^"]*">([^<]*)</span>', raw)
    if "0/0" in tiles:
        problems.append(f"{path.name} 재현 테스트 타일이 0/0 이다")
    return problems


def speculation_sentences(path: Path) -> list[str]:
    hits: list[str] = []
    for sent in _SENT.split(body_text(path)):
        s = sent.strip()
        if s and SPECULATION.search(s):
            hits.append(f"{path.name}: {s[:160]}")
    return hits


def main(argv: list[str]) -> int:
    strict = "--strict" in argv
    paths = [Path(a) for a in argv if a != "--strict"]
    if not paths:
        print(__doc__)
        return 2
    failed = False
    for path in paths:
        if not path.exists():
            print(f"없음: {path}")
            failed = True
            continue
        if path.suffix == ".html":
            problems = check_html(path)
            for pr in problems:
                print("FAIL", pr)
            failed |= bool(problems)
    print("--- 추측 표현 후보(문장마다 읽는다) ---")
    total = 0
    for path in paths:
        if not path.exists():
            continue
        hits = speculation_sentences(path)
        total += len(hits)
        for h in hits:
            print(h)
    print(f"--- 후보 {total}문장 ---")
    if strict and total:
        failed = True
    print("결과:", "실패" if failed else "통과")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
