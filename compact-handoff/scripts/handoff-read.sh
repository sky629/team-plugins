#!/bin/bash
# SessionStart(compact) 훅. handoff-write.sh 가 압축 직전에 남긴
# ~/.claude/handoff/<session_id>.md 를 stdout 으로 내보내 압축 뒤 컨텍스트에 넣고,
# 그 파일을 지운다. 파일이 없으면 아무것도 하지 않는다.
# stdin: {"session_id","source","cwd",...}
set -u
INPUT=$(cat)
HANDOFF_DIR="${CLAUDE_HANDOFF_DIR:-$HOME/.claude/handoff}"
SID=$(printf '%s' "$INPUT" | python3 -I -c 'import json,sys
try: print(json.load(sys.stdin).get("session_id") or "")
except Exception: print("")')
[ -n "$SID" ] || exit 0
FILE="$HANDOFF_DIR/$SID.md"
[ -f "$FILE" ] || exit 0
printf '<handoff source="PreCompact hook, 압축 뒤 한 번만 주입됨">\n'
cat "$FILE"
printf '</handoff>\n'
rm -f "$FILE"
exit 0
