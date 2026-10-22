#!/bin/sh
# SessionStart 훅. 머리말 한 줄과 rules/*.md 를 이어서 표준 출력에 낸다.
# Claude Code 는 이 출력을 세션 컨텍스트에 넣는다(CLAUDE.md 와 같은 효과).
#
# 사용법: print-rules.sh [RULES_DIR]   (기본값: 이 스크립트의 ../rules)
# 실패 조건: .md 파일이 하나도 없거나 출력이 LIMIT 유닛을 넘으면 표준 출력에 아무것도 내지 않고 종료 1.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
rules_dir=${1:-$here/../rules}
limit=10000
header='# kang 팀 작업 규칙 (team-plugins 의 kang-rules 플러그인이 넣은 지침)'

out=$(mktemp)
trap 'rm -f "$out"' EXIT

found=0
{
  printf '%s\n\n' "$header"
  for f in "$rules_dir"/*.md; do
    [ -f "$f" ] || continue
    found=$((found + 1))
    cat "$f"
    # 파일이 개행으로 끝나지 않으면 개행을 보충한 뒤, 파일 사이를 빈 줄 하나로 나눈다.
    if [ -s "$f" ] && [ "$(tail -c1 "$f" | od -An -c | tr -d ' ')" != '\n' ]; then
      printf '\n'
    fi
    printf '\n'
  done
} > "$out"

if [ "$found" -eq 0 ]; then
  echo "print-rules: $rules_dir 에 .md 파일이 없다. scripts/sync-rules.sh 를 먼저 실행했는지 확인하라." >&2
  exit 1
fi

units=$(sh "$here/count-units.sh" < "$out")
if [ "$units" -gt "$limit" ]; then
  echo "print-rules: 출력이 $units 유닛으로 상한 $limit 을 넘는다. 규칙 글을 줄여라." >&2
  exit 1
fi

cat "$out"
