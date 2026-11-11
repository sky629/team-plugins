# 코멘트 형식과 게시 — review-pr 10단계

SKILL.md 10단계가 이 파일을 가리킨다. 초안을 쓰기 전에 "형식"을, 게시 턴에 "게시"를 읽는다. 게시는 사용자 승인 뒤 별도 턴에서 `gh` 로만 한다. 아래 명령의 `N` 은 PR 번호, `$S` 는 산출물 폴더, `$REPO` 는 대상 레포(`owner/name`)다.

## 형식

### 인라인 코멘트 — 크리티컬·메이저만

본문 세 항: ① 심각도 + 한 문장 결론 ② 재현 결과(테스트 이름·관측값) ③ 제안 1개. 구조 원인에 속하면 "원인 A 참조" 한 줄. 코드 블록은 필요할 때만. `side` 는 `RIGHT`, 여러 줄이면 `start_line` + `line`. `line` 은 PR head 기준이고 diff hunk 안이어야 한다(`scripts/check-inline-lines.py`).

### 요약 리뷰 본문 — 순서 고정

1. `## 리뷰 요약 — <판정>`. 재리뷰면 `## 리뷰 요약 — <판정> (재리뷰 <이전 head 7자> → <새 head 7자>)`.
2. `> [!IMPORTANT]` 박스: `### 전체 리뷰 보고서: <Artifact URL>` + "링크가 있는 누구나 열 수 있다" + "같은 링크를 마지막 코멘트에도 두었다". Artifact 없는 환경이면 이 박스가 없고 3번부터 시작한다.
3. 판정 한 줄.
4. 재리뷰면 이전 항목 상태 한 줄 — "이전 n건: 해소 a · 잔존 b · 결정으로 내림 c". 첫 리뷰면 이 줄이 없다.
5. 심각도별 표(항목 · 확인 방법) — 크리티컬·메이저·마이너·중복·미재사용·아키텍처 전부 한 줄씩. 잔존 항목은 확인 방법 칸에 `이전 리뷰 유지`. 마이너 이하는 이 표가 유일한 코멘트 자리다.
6. 구조 진단 단락 — 원인별 한 줄: 결정 → 설명하는 결함 → 근본 수정 / 증상 패치 → 범위 선택 요청.
7. PR 본문 정정 요청(있으면).
8. 검증 한 줄 — 재현 N/N · 안전 사실(증명됨 n/5 | 미증명) · PR 테스트 변이 실행(점검 n·통과 m) · 계약 결과 · 기존 실패 n건(base 동일).

요약 본문 안에서 링크는 2번 박스 한 곳뿐이다. 구조 문제는 인라인이 아니라 여기에 둔다.

### 링크 전용 마지막 코멘트 — Artifact 가 있는 환경에서만

```
## PR #N 전체 리뷰 보고서

### <Artifact URL>

> [!IMPORTANT]
> **링크가 있는 누구나 열 수 있습니다.**
> 담긴 것 — <구조 원인 수 · 크리티컬 · 메이저 · 재현 테스트 N/N · 안전 사실 증명 여부 · 계약 결과> · 항목별 제안. 요약과 인라인 코멘트는 위 리뷰에 있습니다.
```

## 게시 — 승인 뒤 별도 턴, 세션 디렉터리, 순서대로

게시 턴은 `$S/prN-published.json` 을 남기고 끝난다. 이 파일이 재리뷰의 PUT·DELETE·PATCH 대상 id 를 준다.

```json
{"head": "<head sha>", "review_id": 0, "inline_review_ids": [], "link_comment_id": null, "posted_at": "<UTC ISO>"}
```

### 첫 게시

```bash
S="${PR_REVIEW_DIR:-$HOME/.pr-reviews}/prN"; N=<번호>; REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
HEAD=$(gh pr view $N --json headRefOid --jq .headRefOid)
PAYLOAD_HEAD=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["commit_id"])' "$S/pr$N-review.json")
[ "$HEAD" = "$PAYLOAD_HEAD" ] || { echo "HEAD $HEAD ≠ payload $PAYLOAD_HEAD — 중단하고 재리뷰 여부를 묻는다"; false; }
RID=$(gh api -X POST repos/$REPO/pulls/$N/reviews --input "$S/pr$N-review.json" --jq .id)
LID=""; [ -f "$S/pr$N-link-comment.md" ] && LID=$(gh api -X POST repos/$REPO/issues/$N/comments -F body=@"$S/pr$N-link-comment.md" --jq .id)
gh api repos/$REPO/pulls/$N/reviews/$RID/comments --jq length      # 인라인 수가 payload 와 같은지 본다
python3 - "$S/pr$N-published.json" "$HEAD" "$RID" "$LID" <<'PY'
import json, sys, datetime
path, head, rid, lid = sys.argv[1:5]
json.dump({"head": head, "review_id": int(rid), "inline_review_ids": [],
           "link_comment_id": int(lid) if lid else None,
           "posted_at": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")},
          open(path, "w"), ensure_ascii=False, indent=2)
PY
```

### 재리뷰 게시

새 요약 리뷰를 만들지 않는다. 이전 요약 리뷰의 본문을 갱신하고, 인라인은 지우거나 새로 올리고, 링크 코멘트는 고친다.

```bash
S="${PR_REVIEW_DIR:-$HOME/.pr-reviews}/prN"; N=<번호>; REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
HEAD=$(gh pr view $N --json headRefOid --jq .headRefOid)                       # 보고서·상태표의 새 head 와 같아야 한다
RID=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["review_id"])' "$S/pr$N-published.json")
LID=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["link_comment_id"] or "")' "$S/pr$N-published.json")

gh api -X PUT repos/$REPO/pulls/$N/reviews/$RID --input "$S/pr$N-review-body.json"     # 요약 본문 갱신. 파일은 {"body": "…"}

gh api repos/$REPO/pulls/$N/reviews/$RID/comments --jq '.[]|[.id,.path,.line]|@tsv'     # 이전 인라인 목록. inline_review_ids 의 리뷰도 같은 명령으로 본다
gh api -X DELETE repos/$REPO/pulls/comments/<id>                                           # 해소·결정으로 내린 항목의 인라인마다 하나씩

NRID=""
if [ "$(python3 -c 'import json,sys;print(len(json.load(open(sys.argv[1]))["comments"]))' "$S/pr$N-review.json")" != 0 ]; then
  NRID=$(gh api -X POST repos/$REPO/pulls/$N/reviews --input "$S/pr$N-review.json" --jq .id)   # 새 크리티컬·메이저 인라인만. body 는 "재리뷰 인라인 — 요약은 위 리뷰" 한 줄
fi
[ -n "$LID" ] && gh api -X PATCH repos/$REPO/issues/comments/$LID -F body=@"$S/pr$N-link-comment.md"

python3 - "$S/pr$N-published.json" "$HEAD" "$NRID" <<'PY'
import json, sys
path, head, nrid = sys.argv[1:4]
d = json.load(open(path)); d["head"] = head
if nrid: d["inline_review_ids"].append(int(nrid))
json.dump(d, open(path, "w"), ensure_ascii=False, indent=2)
PY
```

- `prN-published.json` 이 없는데 GitHub 에 내 이전 리뷰가 있으면(다른 세션에서 게시) 먼저 id 를 찾아 파일을 만든다: `gh api repos/$REPO/pulls/$N/reviews --jq '.[]|select(.user.login=="'"$(gh api user --jq .login)"'")|[.id,.commit_id,.submitted_at]|@tsv'`, 링크 코멘트는 `gh api repos/$REPO/issues/$N/comments --jq '.[]|select(.body|startswith("## PR #'"$N"' 전체 리뷰 보고서"))|.id'`.
- 다른 사람의 이전 리뷰는 갱신하지 않는다. 그 항목은 후보 처리표에 "출처: 이전 리뷰(<login>)" 로 두고, 내 리뷰는 첫 게시 절차로 올린다.
- Artifact 는 같은 URL 로 재발행했으므로 링크 코멘트의 URL 은 바뀌지 않는다. 바뀌는 것은 "담긴 것" 줄이다.

## 정리

게시 턴이 끝난 뒤의 정리(재현 파일 복사, worktree·ref 삭제, `$S` 에 남는 파일 목록)는 SKILL.md 11단계에 있다.
