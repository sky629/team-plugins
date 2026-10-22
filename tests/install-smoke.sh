#!/bin/sh
# 격리된 설정 디렉터리에서 team-plugins 마켓플레이스를 등록하고 kang-setup 번들을 설치해 본다.
# kang 의 실제 설치(~/.claude)는 건드리지 않는다.
#
# 사용법: tests/install-smoke.sh <마켓플레이스 소스> [--block-ssh] [--keep]
#   <마켓플레이스 소스>  로컬 경로(예: .) 또는 GitHub 축약형(예: sky629/team-plugins)
#   --block-ssh          exit 255 만 하는 가짜 ssh 를 PATH 앞에 둬서 SSH 를 못 쓰게 한다 (HTTPS 폴백 검증)
#   --keep               임시 설정 디렉터리를 지우지 않고 마지막 줄에 경로를 출력한다
# 성공하면 `ok` 를 출력하고 0, 아니면 설치 목록을 찍고 1 로 끝난다.
set -eu

src=${1:?usage: install-smoke.sh <marketplace source> [--block-ssh] [--keep]}
shift
block_ssh=0
keep=0
for a in "$@"; do
  case "$a" in
    --block-ssh) block_ssh=1 ;;
    --keep) keep=1 ;;
    *) echo "install-smoke: unknown option $a" >&2; exit 2 ;;
  esac
done

# `claude plugin marketplace add` 는 `.` 같은 상대 경로를 거부하므로, 디렉터리 소스는 절대 경로로 바꾼다.
if [ -d "$src" ]; then
  src=$(cd "$src" && pwd)
fi

cfg=$(mktemp -d)
fake=""
export CLAUDE_CONFIG_DIR="$cfg"

if [ "$block_ssh" -eq 1 ]; then
  fake=$(mktemp -d)
  printf '#!/bin/sh\nexit 255\n' > "$fake/ssh"
  chmod +x "$fake/ssh"
  PATH="$fake:$PATH"
  export PATH
fi

cleanup() {
  if [ "$keep" -eq 0 ]; then rm -r "$cfg"; fi
  if [ -n "$fake" ]; then rm -r "$fake"; fi
}
trap cleanup EXIT

echo "config dir: $cfg"
claude plugin marketplace add "$src"
# 새 설정 디렉터리에는 공식 마켓플레이스가 아직 없다. 인터랙티브 세션은 자동 등록하지만 쉘 명령은 하지 않으므로,
# superpowers@claude-plugins-official 의존성을 받으려면 먼저 등록해야 한다. (실측: 2026-10-22, Claude Code 2.1.306)
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install kang-setup@team-plugins

ids=$(claude plugin list --json | jq -r '.[] | select(.enabled) | .id')
missing=0
for want in kang-setup@team-plugins kang-rules@team-plugins andrej-karpathy-skills@team-plugins \
            diagram-design@team-plugins eli5@team-plugins superpowers@claude-plugins-official; do
  if ! printf '%s\n' "$ids" | grep -qx "$want"; then
    echo "missing or disabled: $want" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  claude plugin list
  exit 1
fi

echo ok
if [ "$keep" -eq 1 ]; then echo "$cfg"; fi
