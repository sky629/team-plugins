#!/bin/sh
# team-plugins 스크립트 단위 테스트. 레포 루트에서 `sh tests/test-scripts.sh` 로 실행한다.
# 케이스가 하나라도 실패하면 종료 코드 1.
set -u
cd "$(dirname "$0")/.." || exit 2

fails=0
tmp_root=${TMPDIR:-/tmp}
tmp_root=${tmp_root%/}

# check <이름> <조건 명령...>: 조건이 0 으로 끝나면 ok, 아니면 FAIL 을 찍고 실패를 센다.
check() {
  name=$1
  shift
  if "$@"; then
    echo "ok $name"
  else
    echo "FAIL $name"
    fails=$((fails + 1))
  fi
}

# cleanup <경로>: mktemp -d 로 만든 임시 디렉터리만 지운다. 다른 경로는 거부한다.
cleanup() {
  case "$1" in
    "$tmp_root"/*) rm -r "$1" ;;
    *) echo "cleanup: $1 은 $tmp_root 아래가 아니라서 지우지 않는다" >&2 ;;
  esac
}

# ---- 마켓플레이스 ----
# kang-setup·kang-rules 는 설계상 version 을 두지 않는다(커밋이 곧 릴리스). 그래서 validate 는
# "No version specified" 경고를 낸다. 이 경고 하나만 허용하고, 다른 경고·오류는 실패로 본다.
validate_out=$(claude plugin validate . 2>&1)
check validate_passes                   sh -c "printf '%s\n' \"\$1\" | tail -1 | grep -q 'Validation passed'" _ "$validate_out"
check validate_no_unexpected_warnings   test -z "$(printf '%s\n' "$validate_out" | grep -F '❯' | grep -v 'version: No version specified')"

# ---- kang-rules/scripts/count-units.sh ----
check count_units_counts_korean_as_one   test "$(printf '한글\n' | sh kang-rules/scripts/count-units.sh)" = 3
check count_units_counts_ascii           test "$(printf 'abc' | sh kang-rules/scripts/count-units.sh)" = 3
check count_units_empty_is_zero          test "$(printf '' | sh kang-rules/scripts/count-units.sh)" = 0

# ---- kang-rules/scripts/print-rules.sh: 정상 ----
d=$(mktemp -d); printf 'A' > "$d/10-a.md"; printf 'B\n' > "$d/20-b.md"
out=$(sh kang-rules/scripts/print-rules.sh "$d")
check print_rules_header_first           test "$(printf '%s\n' "$out" | head -1)" = "# kang 팀 작업 규칙 (team-plugins 의 kang-rules 플러그인이 넣은 지침)"
check files_are_separated_by_blank_line  test "$(printf '%s\n' "$out" | sed -n '3,5p')" = "$(printf 'A\n\nB')"
cleanup "$d"

# ---- print-rules.sh: 빈 디렉터리 ----
d=$(mktemp -d)
check empty_rules_dir_fails              sh -c "! sh kang-rules/scripts/print-rules.sh '$d' >/dev/null 2>&1"
check empty_rules_dir_prints_nothing     test -z "$(sh kang-rules/scripts/print-rules.sh "$d" 2>/dev/null)"
cleanup "$d"

# ---- print-rules.sh: 상한 초과 ----
d=$(mktemp -d); head -c 10001 /dev/zero | tr '\0' 'a' > "$d/big.md"
check over_limit_fails                   sh -c "! sh kang-rules/scripts/print-rules.sh '$d' >/dev/null 2>&1"
check over_limit_prints_nothing          test -z "$(sh kang-rules/scripts/print-rules.sh "$d" 2>/dev/null)"
cleanup "$d"

# ---- scripts/sync-rules.sh: 정상 ----
src=$(mktemp -d); dst=$(mktemp -d)
printf '@RTK.md\n@KOREAN.md\n\nrule A %%s\n' > "$src/CLAUDE.md"; printf '한국어 지침\n' > "$src/KOREAN.md"
check sync_ok              sh -c "KANG_RULES_SRC='$src' KANG_RULES_DEST='$dst' sh scripts/sync-rules.sh >/dev/null"
check sync_strips_imports  test "$(cat "$dst/10-claude-md.md")" = "$(printf '\nrule A %%s')"
check sync_copies_korean   test "$(cat "$dst/20-korean.md")" = "한국어 지침"
check sync_reports_count   sh -c "KANG_RULES_SRC='$src' KANG_RULES_DEST='$dst' sh scripts/sync-rules.sh | tail -1 | grep -q '^rules: [0-9][0-9]* / 10000$'"
cleanup "$src"; cleanup "$dst"

# ---- sync-rules.sh: 원본 누락 ----
src=$(mktemp -d); dst=$(mktemp -d); printf 'x\n' > "$src/CLAUDE.md"
check sync_missing_source_fails           sh -c "! KANG_RULES_SRC='$src' KANG_RULES_DEST='$dst' sh scripts/sync-rules.sh >/dev/null 2>&1"
check sync_missing_source_writes_nothing  test -z "$(ls -A "$dst")"
cleanup "$src"; cleanup "$dst"

# ---- sync-rules.sh: 상한 초과면 DEST 그대로 ----
src=$(mktemp -d); dst=$(mktemp -d); printf 'keep\n' > "$dst/10-claude-md.md"
head -c 10001 /dev/zero | tr '\0' 'a' > "$src/CLAUDE.md"; printf 'k\n' > "$src/KOREAN.md"
check sync_over_limit_fails                  sh -c "! KANG_RULES_SRC='$src' KANG_RULES_DEST='$dst' sh scripts/sync-rules.sh >/dev/null 2>&1"
check sync_over_limit_leaves_dest_untouched  test "$(cat "$dst/10-claude-md.md")" = keep
cleanup "$src"; cleanup "$dst"

# ---- 결과 ----
if [ "$fails" -ne 0 ]; then
  echo "$fails failed"
  exit 1
fi
echo "all ok"
