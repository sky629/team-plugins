# team-plugins

kang 이 쓰는 Claude Code 플러그인과 작업 규칙을 한곳에 모은 마켓플레이스입니다. 필요한 것만 골라서 설치할 수도 있고, `kang-setup` 하나로 전부 설치할 수도 있습니다.

## 들어 있는 것

| 이름 | 종류 | 설명 | 출처 |
|---|---|---|---|
| `kang-setup` | 번들 | 아래 플러그인 전부를 한 번에 설치합니다. 자체 기능은 없습니다. | 이 레포 |
| `kang-rules` | 작업 규칙 | kang 의 전역 CLAUDE.md(답변 규율, 문제 해결 원칙, 한국어 작성 지침)를 매 세션 컨텍스트에 넣는 훅입니다. | 이 레포 [`kang-rules/rules/`](kang-rules/rules/) |
| `andrej-karpathy-skills` | 스킬 | LLM 코딩 실수를 줄이는 행동 지침 스킬(`karpathy-guidelines`)입니다. | [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) |
| `diagram-design` | 스킬 | 브랜드를 적용한 아키텍처·흐름도·차트 다이어그램을 HTML/SVG/PNG 로 만드는 스킬입니다. 스킬이 호출하는 스크립트(node·python) 60여 개가 들어 있습니다. | [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) |
| `eli5` | 스킬 | 주제를 다섯 살에게 설명하듯 그림 설명서로 풀어 주는 스킬입니다. | [anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) |
| `superpowers` | 작업 절차 | 브레인스토밍, 계획, TDD, 코드 리뷰 등 개발 절차 스킬 모음입니다. | 공식 마켓플레이스 `claude-plugins-official` (번들 의존성으로 설치) |
| `context7` | MCP 서버 | 라이브러리·프레임워크의 최신 공식 문서를 조회하는 MCP 서버입니다. | 공식 마켓플레이스 `claude-plugins-official` (번들 의존성으로 설치) |
| `compact-handoff` | 훅 | 자동 압축 직전에 세션 기록(최근 요청·고친 파일·git 상태)을 핸드오프 문서로 저장하고, 압축 뒤 컨텍스트에 넣은 다음 지우는 훅입니다. python3 가 필요합니다. | 이 레포 [`compact-handoff/`](compact-handoff/) |
| `pstack` | 작업 절차 | 설계·구현·검증·리뷰를 서브에이전트로 병렬화하는 엄격한 워크플로 스킬 모음(`poteto-mode`, `how`, `why`, `arena` 등)입니다. 스킬이 호출하는 스크립트(sh·node)가 들어 있습니다. 설치 뒤 `/setup-pstack` 으로 역할별 모델을 정할 수 있습니다. | [cursor/plugins](https://github.com/cursor/plugins/tree/main/harness/pstack/claude-code) |
| `make-notion` | 스킬 | git 브랜치에서 한 작업을 비개발자가 읽을 수 있는 설계 공유 문서로 정리해 노션 인덱스 페이지의 하위 페이지로 남기는 스킬(`make_notion`)입니다. 조사에는 pstack 의 `teach`·`how`·`why` 를 쓰고, 그림은 `diagram-design` 으로 그려 PNG 로 첨부합니다. Notion 플러그인과 [ego lite](https://github.com/citrolabs/ego-lite)(`ego-browser` CLI)가 필요합니다. | 이 레포 [`make-notion/`](make-notion/) |
| `review-pr` | 스킬 | GitHub PR 하나를 5축(크리티컬·중복·미재사용·아키텍처·구조 진단)으로 검토하는 스킬입니다. 재현한 문제만 HTML 보고서와 코멘트 초안으로 내고, 게시는 승인 뒤에 합니다. 레포마다 다른 명령은 `.claude/review-pr.md` 프로필에서 읽습니다. `gh`·`git`·`python3` 가 필요합니다. | 이 레포 [`review-pr/`](review-pr/) |

스킬 플러그인 4개(`andrej-karpathy-skills`, `diagram-design`, `eli5`, `pstack`)는 업스트림 레포를 그대로 참조합니다. 이 레포에는 복사본이 없습니다. `andrej-karpathy-skills` 와 `eli5` 는 마크다운만 있습니다. `diagram-design` 과 `pstack` 은 스킬이 실행하는 스크립트를 포함하므로, 업데이트하면 그 스크립트도 새 버전으로 바뀝니다. kang 이 같은 조건으로 쓰고 있어서 커밋을 고정하지 않기로 했습니다.

## 전체 설치

Claude Code 세션 안에서 두 줄을 실행합니다.

```
/plugin marketplace add sky629/team-plugins
/plugin install kang-setup@team-plugins
```

설치가 끝나면 `/reload-plugins` 를 실행하거나 세션을 다시 시작합니다. GitHub SSH 키는 필요 없습니다. SSH 가 안 되면 HTTPS 로 넘어갑니다. 축약형 대신 `https://github.com/sky629/team-plugins.git` 을 써도 같은 마켓플레이스가 등록됩니다.

superpowers 와 context7 은 공식 마켓플레이스에서 함께 설치됩니다. 설치 결과에 `superpowers@claude-plugins-official was not installed` 가 보이면 공식 마켓플레이스가 아직 등록되지 않은 것이므로, `/plugin marketplace add anthropics/claude-plugins-official` 을 실행한 뒤 다시 설치합니다.

쉘에서 설치하려면 다음 순서로 실행합니다. 새 머신에서는 공식 마켓플레이스를 먼저 등록해야 superpowers 와 context7 이 설치됩니다.

```sh
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add sky629/team-plugins
claude plugin install kang-setup@team-plugins
```

## 골라 설치

이름만 바꾸면 됩니다. 쓸 수 있는 이름은 위 표의 `이름` 열입니다.

```
/plugin install diagram-design@team-plugins
```

## kang-rules 가 하는 일과 끄는 법

`kang-rules` 는 세션이 시작될 때마다(새 세션, 재개, `/clear`, 컴팩션 뒤) [`10-claude-md.md`](kang-rules/rules/10-claude-md.md) 와 [`20-korean.md`](kang-rules/rules/20-korean.md) 를 컨텍스트에 넣습니다. 자기 CLAUDE.md 와 함께 적용되며, 두 지침이 충돌할 때 어느 쪽이 우선되는지는 보장되지 않습니다. 충돌하는 규칙이 있으면 끄는 것을 권합니다.

`kang-rules` 는 `kang-setup` 의 의존성이라서 혼자 끌 수 없습니다(`kang-rules is still required by kang-setup`). 번들과 함께 끕니다.

```sh
claude plugin disable kang-setup@team-plugins && claude plugin disable kang-rules@team-plugins
```

번들은 자체 기능이 없어서 꺼도 잃는 것이 없고, 나머지 플러그인은 그대로 켜져 있습니다. 다시 켜려면 `claude plugin enable kang-rules@team-plugins` 를 실행합니다.

## compact-handoff 가 하는 일과 70% 임계값

자동 압축 요약은 최근 요청과 고친 파일을 빠뜨리기 쉽습니다. `compact-handoff` 는 그 사실을 트랜스크립트에서 기계적으로 뽑아 보완합니다.

1. 압축 직전(`PreCompact`)에 [`handoff-write.sh`](compact-handoff/scripts/handoff-write.sh) 가 `~/.claude/handoff/<session_id>.md` 를 씁니다. 작업 디렉터리와 git 상태, 최근 사용자 요청 12개, 최근 Bash 작업 설명 10개, 이 세션에서 고친 파일 목록, 마지막 답변 앞부분이 들어갑니다. 7일 지난 핸드오프 파일은 이때 지웁니다.
2. 압축 뒤 세션이 다시 시작될 때(`SessionStart`, matcher `compact`) [`handoff-read.sh`](compact-handoff/scripts/handoff-read.sh) 가 그 문서를 `<handoff>` 블록으로 컨텍스트에 넣고 파일을 지웁니다. 문서가 없으면 아무것도 하지 않습니다.

두 스크립트는 bash 와 python3 를 씁니다. 압축 없이 끝난 세션의 문서는 다음 압축 때 7일 기준으로 정리됩니다.

압축 임계값은 플러그인이 바꿀 수 없습니다. 70% 에서 압축되게 하려면 `~/.claude/settings.json` 의 `env` 에 다음 값을 넣습니다. 환경 변수이므로 새로 시작하는 세션부터 적용됩니다.

```json
{ "env": { "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70" } }
```

`compact-handoff` 도 `kang-setup` 의 의존성이라서 혼자 끌 수 없습니다. 끄려면 `kang-rules` 와 같은 방법으로 번들과 함께 끕니다.

```sh
claude plugin disable kang-setup@team-plugins && claude plugin disable compact-handoff@team-plugins
```

## make-notion 과 review-pr

두 스킬은 `kang-setup` 번들에 들어 있지 않습니다. 필요한 사람이 따로 설치합니다.

```
/plugin install make-notion@team-plugins
/plugin install review-pr@team-plugins
```

- `make-notion`: 노션 인덱스 페이지(예: "<이름> Task 현황")의 이름이나 URL 을 처음 한 번 알려 주면 됩니다. Notion 플러그인(`notion@claude-plugins-official`)과 `diagram-design` 은 필수이고, `pstack` 이 있으면 조사 단계에 씁니다.
- `review-pr`: 리뷰할 레포의 체크아웃에서 실행합니다. 레포에 `.claude/review-pr.md`(서브트리별 테스트 러너·검증 명령·규칙 문서 목록)가 있으면 그것을 쓰고, 없으면 CI 워크플로와 규칙 문서에서 찾아 씁니다. `pstack` 과 Codex CLI 가 있으면 적대 리뷰 후보를 더 모읍니다.

## 업데이트

- **수동**: `/plugin marketplace update team-plugins` 를 실행한 뒤 `claude plugin update <이름>@team-plugins` 를 실행하고, `/reload-plugins` 로 적용합니다. 번들에 새 플러그인이 추가됐으면 `claude plugin update kang-setup@team-plugins` 뒤 `/reload-plugins` 가 새 의존성을 설치합니다.
- **자동**: `/plugin` → Marketplaces → team-plugins → Enable auto-update 를 켭니다. 기본값은 꺼짐입니다.
- **버전 규칙**: `kang-setup`, `kang-rules`, `compact-handoff`, `make-notion`, `review-pr` 는 이 레포의 커밋이 곧 새 버전입니다. 스킬 플러그인 4개는 업스트림이 `version` 을 올릴 때 따라갑니다.
- **번들 제거**: `claude plugin uninstall kang-setup@team-plugins` 를 실행해도 의존성 플러그인은 남습니다. 의존성까지 전부 지우려면 `claude plugin prune` 을 실행합니다. 이 명령은 자동 설치된 플러그인 8개(superpowers, context7, pstack, compact-handoff 포함)를 모두 지우므로, `--dry-run` 으로 먼저 확인합니다.

## 이미 설치한 사람

다른 마켓플레이스(`karpathy-skills`, `diagram-design`, `claude-community`, `cursor-plugins`)에서 같은 플러그인을 이미 설치했어도 그대로 두고 설치해도 됩니다. 두 개가 나란히 켜지고 스킬이 목록에 두 번 보일 뿐, 오류는 없습니다(실측: 두 플러그인의 스킬이 모두 로드되고 충돌 없음). 하나만 두고 싶으면 옛것을 지웁니다.

```sh
claude plugin uninstall diagram-design@diagram-design
```

## 라이선스

MIT
