#!/bin/sh
# 표준 입력의 글자 수를 UTF-16 코드 유닛 단위로 센다.
# Claude Code 가 훅 출력 상한(10,000)을 재는 JS 문자열 길이와 같은 단위이며, 로케일에 의존하지 않는다.
set -eu
bytes=$(iconv -f UTF-8 -t UTF-16LE | wc -c | tr -d ' ')
echo $((bytes / 2))
