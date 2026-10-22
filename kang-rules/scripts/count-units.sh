#!/bin/sh
# 표준 입력의 글자 수를 UTF-16 코드 유닛 단위로 센다.
# Claude Code 가 훅 출력 상한(10,000)을 재는 JS 문자열 길이와 같은 단위이며, 로케일에 의존하지 않는다.
# iconv 가 없거나 변환에 실패하면 수를 내지 않고 1 로 끝난다. 0 이나 부분값을 내면 상한 검사가 조용히 통과하기 때문이다.
set -eu
command -v iconv >/dev/null 2>&1 || { echo "count-units: iconv 가 없다. 글자 수를 셀 수 없다." >&2; exit 1; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
iconv -f UTF-8 -t UTF-16LE > "$tmp" || { echo "count-units: iconv 변환에 실패했다. 입력이 올바른 UTF-8 인지 확인하라." >&2; exit 1; }
bytes=$(wc -c < "$tmp" | tr -d ' ')
echo $((bytes / 2))
