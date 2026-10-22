#!/bin/sh
# kang 의 전역 지침(~/.claude/CLAUDE.md, KOREAN.md)을 kang-rules/rules/ 로 복사한다.
# 복사 방향은 ~/.claude → 레포. 이 스크립트로만 rules/ 를 갱신한다.
#
# 환경 변수:
#   KANG_RULES_SRC   원본 디렉터리 (기본값 $HOME/.claude)
#   KANG_RULES_DEST  대상 디렉터리 (기본값 <레포 루트>/kang-rules/rules)
# 실패 조건: 원본 파일이 하나라도 없거나 합계가 상한을 넘으면 DEST 를 건드리지 않고 종료 1.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
src=${KANG_RULES_SRC:-$HOME/.claude}
dest=${KANG_RULES_DEST:-$root/kang-rules/rules}
print_rules="$root/kang-rules/scripts/print-rules.sh"
count_units="$root/kang-rules/scripts/count-units.sh"

for f in CLAUDE.md KOREAN.md; do
  if [ ! -f "$src/$f" ]; then
    echo "sync-rules: $src/$f 가 없다." >&2
    exit 1
  fi
done

stage=$(mktemp -d)
trap 'rm -r "$stage"' EXIT

# CLAUDE.md 본문에서 @import 줄(@RTK.md, @KOREAN.md)은 뺀다. KOREAN.md 는 같은 출력에 이어 붙는다.
grep -v '^@' "$src/CLAUDE.md" > "$stage/10-claude-md.md" || true
cp "$src/KOREAN.md" "$stage/20-korean.md"

# print-rules.sh 가 상한(10,000 유닛)을 검사한다. 넘으면 여기서 끝나고 DEST 는 그대로다.
rendered=$(sh "$print_rules" "$stage")

mkdir -p "$dest"
cp "$stage/10-claude-md.md" "$stage/20-korean.md" "$dest/"

units=$(printf '%s\n' "$rendered" | sh "$count_units")
echo "rules: $units / 10000"
