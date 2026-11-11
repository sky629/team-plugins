#!/usr/bin/env bash
# 현재 git 브랜치의 작업 내용을 베이스 브랜치 대비로 수집한다.
# 노션 'Task 현황' 기록을 위한 결정적 입력(커밋 로그 + diff)을 만든다.
#
# 사용법:  gather_branch_work.sh [base-branch]
#   base-branch 미지정 시 origin/develop → develop → origin/main → main 순으로 자동 탐색.
#   원격 추적 브랜치를 먼저 고른다. 로컬 베이스가 뒤처져 있으면 다른 사람의 커밋이 이 브랜치 작업으로 섞인다.
#
# 출력은 사람이 읽기 쉬운 섹션 형태(## ...)이며, 스킬이 이를 요약 근거로 사용한다.
set -euo pipefail

REQUESTED_BASE="${1:-develop}"

# 베이스 브랜치 해석: origin/요청값 → 요청값 → origin/develop → develop → origin/main → main 순.
resolve_base() {
  for cand in "origin/$REQUESTED_BASE" "$REQUESTED_BASE" "origin/develop" "develop" "origin/main" "main"; do
    if git rev-parse --verify --quiet "$cand" >/dev/null 2>&1; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

BASE="$(resolve_base)" || { echo "ERROR: 베이스 브랜치를 찾지 못했습니다 (develop/main 없음)"; exit 1; }
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# merge-base 기준 3-dot: 베이스가 앞서간 변경은 제외하고 '이 브랜치가 추가한 것'만.
RANGE="${BASE}...HEAD"

if [ "$(git rev-list --count --no-merges "${BASE}..HEAD")" -eq 0 ]; then
  echo "WARNING: '$BRANCH' 에는 '$BASE' 대비 커밋이 없습니다. 이미 머지된 작업이면 PR 번호로 수집하십시오 (gh pr view <N> --json commits,files,body)."
  echo
fi

echo "## BRANCH"
echo "$BRANCH"
echo
echo "## BASE"
echo "$BASE"
echo
echo "## COMMITS (newest first, merge 제외)"
# log 의 3-dot 은 대칭 차집합이라 베이스 쪽 커밋까지 나온다. 이 브랜치의 커밋만 보려면 2-dot 을 쓴다.
git log --no-merges --pretty=format:'- %h %s' "${BASE}..HEAD" || true
echo
echo
echo "## DIFFSTAT"
git diff --stat "$RANGE" || true
echo
echo "## FILES CHANGED (status)"
git diff --name-status "$RANGE" || true
echo
echo "## UNCOMMITTED (working tree, 참고용)"
git status --short || true
