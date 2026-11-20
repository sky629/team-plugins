#!/bin/bash
# SessionStart(startup) 훅. 자동 압축 임계값이 정해져 있지 않으면 ~/.claude/settings.json 의
# env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE 에 기본값을 넣는다.
# 이미 값이 있으면(어느 설정 파일에서 왔든) 아무것도 하지 않는다. 사용자가 정한 값을 덮어쓰지 않는다.
# 환경 변수는 세션이 시작될 때 읽히므로, 넣은 값은 다음 세션부터 적용된다.
set -u
cat >/dev/null
DEFAULT_PCT=60
# 이 훅은 Claude Code 프로세스의 환경을 물려받는다. 변수가 이미 있으면 설정이 끝난 상태다.
[ -z "${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-}" ] || exit 0
SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

SETTINGS="$SETTINGS" DEFAULT_PCT="$DEFAULT_PCT" python3 -I - <<'PY'
import json, os, shutil, sys

path = os.environ["SETTINGS"]
pct = os.environ["DEFAULT_PCT"]
key = "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE"
manual = f'~/.claude/settings.json 의 env 에 "{key}": "{pct}" 를 직접 넣으십시오.'

def say(msg):
    print(json.dumps({"systemMessage": f"compact-handoff: {msg}"}, ensure_ascii=False))

data = {}
if os.path.exists(path):
    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except Exception:
        say(f"settings.json 을 읽지 못해 자동 압축 임계값을 넣지 않았습니다. {manual}")
        sys.exit(0)
    if not isinstance(data, dict):
        say(f"settings.json 의 형식이 예상과 달라 자동 압축 임계값을 넣지 않았습니다. {manual}")
        sys.exit(0)

env = data.get("env")
if env is None:
    env = data["env"] = {}
if not isinstance(env, dict):
    say(f"settings.json 의 env 형식이 예상과 달라 자동 압축 임계값을 넣지 않았습니다. {manual}")
    sys.exit(0)
if key in env:
    sys.exit(0)

env[key] = pct
try:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if os.path.exists(path):
        backup = path + ".bak-compact-handoff"
        if not os.path.exists(backup):
            shutil.copy2(path, backup)
    tmp = path + ".tmp-compact-handoff"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    os.replace(tmp, path)
except Exception as exc:
    say(f"settings.json 에 쓰지 못했습니다({exc}). {manual}")
    sys.exit(0)

say(f"자동 압축 임계값을 {pct}% 로 설정했습니다(settings.json 의 env.{key}). 다음 세션부터 적용됩니다. 다른 값을 쓰려면 그 값을 고치십시오.")
PY
exit 0
