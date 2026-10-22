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
check validate_strict_passes sh -c 'claude plugin validate --strict . 2>&1 | tail -1 | grep -q "Validation passed"'

# ---- 결과 ----
if [ "$fails" -ne 0 ]; then
  echo "$fails failed"
  exit 1
fi
echo "all ok"
