# team-plugins

kang 이 쓰는 Claude Code 플러그인과 작업 규칙을 한곳에 모은 마켓플레이스입니다. 필요한 것만 골라서 설치할 수도 있고, `kang-setup` 하나로 전부 설치할 수도 있습니다.

## 들어 있는 것

| 이름 | 종류 | 설명 | 출처 |
|---|---|---|---|
| `kang-setup` | 번들 | 아래 플러그인 전부를 한 번에 설치합니다. 자체 기능은 없습니다. | 이 레포 |
| `kang-rules` | 작업 규칙 | kang 의 전역 CLAUDE.md(코딩 지침, 문제 해결 원칙, 작업 규칙, 답변 규율, 한국어 작성 지침)를 매 세션 컨텍스트에 넣는 훅입니다. 코딩 지침은 [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)(MIT)의 지침을 고쳐 넣은 것입니다([`NOTICE.md`](kang-rules/NOTICE.md)). | 이 레포 [`kang-rules/rules/`](kang-rules/rules/) |
| `diagram-design` | 스킬 | 브랜드를 적용한 아키텍처·흐름도·차트 다이어그램을 HTML/SVG/PNG 로 만드는 스킬입니다. 스킬이 호출하는 스크립트(node·python) 60여 개가 들어 있습니다. | [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) |
| `eli5` | 스킬 | 주제를 다섯 살에게 설명하듯 그림 설명서로 풀어 주는 스킬입니다. | [anthropics/claude-plugins-community](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) |
| `context7` | MCP 서버 | 라이브러리·프레임워크의 최신 공식 문서를 조회하는 MCP 서버입니다. | 공식 마켓플레이스 `claude-plugins-official` (번들 의존성으로 설치) |
| `notion` | MCP 서버 | 노션 페이지를 조회하고 만들고 고치는 MCP 서버와 스킬입니다. `make-notion` 이 씁니다. 설치 뒤 Notion 로그인이 필요합니다. | 공식 마켓플레이스 `claude-plugins-official` (번들 의존성으로 설치) |
| `compact-handoff` | 훅 | 자동 압축 직전에 세션 기록(최근 요청·고친 파일·git 상태)을 핸드오프 문서로 저장하고, 압축 뒤 컨텍스트에 넣은 다음 지우는 훅입니다. python3 가 필요합니다. | 이 레포 [`compact-handoff/`](compact-handoff/) |
| `pstack` | 작업 절차 | 설계·구현·검증·리뷰를 서브에이전트로 병렬화하는 엄격한 워크플로 스킬 모음(`poteto-mode`, `how`, `why`, `arena` 등)입니다. 스킬이 호출하는 스크립트(sh·node)가 들어 있습니다. 설치 뒤 `/setup-pstack` 으로 역할별 모델을 정할 수 있습니다. | [cursor/plugins](https://github.com/cursor/plugins/tree/main/harness/pstack/claude-code) |
| `make-notion` | 스킬 | git 브랜치에서 한 작업을 비개발자가 읽을 수 있는 설계 공유 문서로 정리해 노션 인덱스 페이지의 하위 페이지로 남기는 스킬(`make_notion`)입니다. 조사에는 pstack 의 `teach`·`how`·`why` 를 쓰고, 그림은 `diagram-design` 으로 그려 PNG 로 첨부합니다. Notion 플러그인과 [ego lite](https://github.com/citrolabs/ego-lite)(`ego-browser` CLI)가 필요합니다. | 이 레포 [`make-notion/`](make-notion/) |
| `review-pr` | 스킬 | GitHub PR 하나를 5축(크리티컬·중복·미재사용·아키텍처·구조 진단)으로 검토하는 스킬입니다. 재현한 문제만 HTML 보고서와 코멘트 초안으로 내고, 게시는 승인 뒤에 합니다. 레포마다 다른 명령은 `.claude/review-pr.md` 프로필에서 읽습니다. `gh`·`git`·`python3` 가 필요합니다. | 이 레포 [`review-pr/`](review-pr/) |
| `spec-flow` | 스킬 | 새 기능을 구현하기 전후에 쓰는 스킬 두 개입니다. `make_spec` 은 사용자가 원하는 것과 이유를 대화로 확인해 스펙을 쓰고 승인받습니다. `run_final_check` 는 구현 뒤에 드래프트 PR 을 만들고, 서브에이전트로 자기 리뷰를 돌려 고친 뒤, 승인을 받아 게시하고 Ready 로 바꿉니다. 둘 다 수동 호출이고 `pstack` 과 함께 씁니다. `make_spec` 의 대화 절차는 [obra/superpowers](https://github.com/obra/superpowers)(MIT)의 `brainstorming` 을 고쳐 옮긴 것입니다([`NOTICE.md`](spec-flow/NOTICE.md)). | 이 레포 [`spec-flow/`](spec-flow/) |

스킬 플러그인 3개(`diagram-design`, `eli5`, `pstack`)는 업스트림 레포를 그대로 참조합니다. 이 레포에는 복사본이 없습니다. `eli5` 는 마크다운만 있습니다. `diagram-design` 과 `pstack` 은 스킬이 실행하는 스크립트를 포함하므로, 업데이트하면 그 스크립트도 새 버전으로 바뀝니다. kang 이 같은 조건으로 쓰고 있어서 커밋을 고정하지 않기로 했습니다.

## 전체 설치

Claude Code 세션 안에서 두 줄을 실행합니다.

```
/plugin marketplace add sky629/team-plugins
/plugin install kang-setup@team-plugins
```

설치가 끝나면 `/reload-plugins` 를 실행하거나 세션을 다시 시작합니다. GitHub SSH 키는 필요 없습니다. SSH 가 안 되면 HTTPS 로 넘어갑니다. 축약형 대신 `https://github.com/sky629/team-plugins.git` 을 써도 같은 마켓플레이스가 등록됩니다.

context7 과 notion 은 공식 마켓플레이스에서 함께 설치됩니다. 설치 결과에 `context7@claude-plugins-official was not installed` 가 보이면 공식 마켓플레이스가 아직 등록되지 않은 것이므로, `/plugin marketplace add anthropics/claude-plugins-official` 을 실행한 뒤 다시 설치합니다.

쉘에서 설치하려면 다음 순서로 실행합니다. 새 머신에서는 공식 마켓플레이스를 먼저 등록해야 context7 과 notion 이 설치됩니다.

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

## compact-handoff 가 하는 일과 60% 임계값

자동 압축 요약은 최근 요청과 고친 파일을 빠뜨리기 쉽습니다. `compact-handoff` 는 그 사실을 트랜스크립트에서 기계적으로 뽑아 보완합니다.

1. 압축 직전(`PreCompact`)에 [`handoff-write.sh`](compact-handoff/scripts/handoff-write.sh) 가 `~/.claude/handoff/<session_id>.md` 를 씁니다. 작업 디렉터리와 git 상태, 최근 사용자 요청 12개, 최근 Bash 작업 설명 10개, 이 세션에서 고친 파일 목록, 마지막 답변 앞부분이 들어갑니다. 7일 지난 핸드오프 파일은 이때 지웁니다.
2. 압축 뒤 세션이 다시 시작될 때(`SessionStart`, matcher `compact`) [`handoff-read.sh`](compact-handoff/scripts/handoff-read.sh) 가 그 문서를 `<handoff>` 블록으로 컨텍스트에 넣고 파일을 지웁니다. 문서가 없으면 아무것도 하지 않습니다.

스크립트는 bash 와 python3 를 씁니다. 압축 없이 끝난 세션의 문서는 다음 압축 때 7일 기준으로 정리됩니다.

### 압축 임계값 60% (설정이 필요합니다)

이 플러그인은 컨텍스트 사용량이 60% 에 닿았을 때 압축되는 것을 전제로 합니다. Claude Code 의 기본 임계값은 이보다 높아서, 임계값을 낮추지 않으면 압축이 늦게 일어나고 핸드오프 문서도 그만큼 늦게 만들어집니다. 임계값은 `~/.claude/settings.json` 의 `env` 에 있는 다음 값으로 정합니다.

```json
{ "env": { "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "60" } }
```

**값이 없으면 플러그인이 자동으로 넣습니다.** 세션이 시작될 때 [`ensure-threshold.sh`](compact-handoff/scripts/ensure-threshold.sh) 가 다음 순서로 동작합니다.

1. `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` 가 이미 정해져 있으면 아무것도 하지 않습니다. 사용자가 정한 값(예: `"70"`)을 덮어쓰지 않습니다.
2. 값이 없으면 `~/.claude/settings.json` 을 `settings.json.bak-compact-handoff` 로 한 번 백업하고, `env` 에 `"60"` 을 넣습니다. 다른 설정은 그대로 둡니다.
3. 넣었다는 메시지를 화면에 보여 줍니다.
4. `settings.json` 을 읽을 수 없으면 파일을 건드리지 않고, 직접 넣으라는 메시지를 보여 줍니다.

환경 변수는 세션이 시작될 때 읽히므로 **넣은 값은 다음 세션부터 적용됩니다.** 설치한 뒤 세션을 한 번 다시 시작해야 60% 로 동작합니다. 적용되었는지는 새 세션에서 `echo $CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` 로 확인합니다.

다른 임계값을 쓰려면 `settings.json` 의 값을 고칩니다. 자동 설정을 원하지 않으면 플러그인을 켜기 전에 원하는 값을 먼저 넣어 둡니다.

`compact-handoff` 도 `kang-setup` 의 의존성이라서 혼자 끌 수 없습니다. 끄려면 `kang-rules` 와 같은 방법으로 번들과 함께 끕니다.

```sh
claude plugin disable kang-setup@team-plugins && claude plugin disable compact-handoff@team-plugins
```

## make-notion 과 review-pr

두 스킬은 `kang-setup` 번들에 들어 있습니다. 번들 없이 따로 설치할 수도 있습니다.

```
/plugin install make-notion@team-plugins
/plugin install review-pr@team-plugins
```

- `make-notion`: 노션 인덱스 페이지(예: "<이름> Task 현황")의 이름이나 URL 을 처음 한 번 알려 주면 됩니다. Notion 플러그인(`notion@claude-plugins-official`)과 `diagram-design` 은 필수이며 번들로 설치하면 함께 설치됩니다. 따로 설치할 때는 두 플러그인을 직접 설치합니다. `pstack` 이 있으면 조사 단계에 씁니다.
- `review-pr`: 리뷰할 레포의 체크아웃에서 실행합니다. 레포에 `.claude/review-pr.md`(서브트리별 테스트 러너·검증 명령·규칙 문서 목록)가 있으면 그것을 쓰고, 없으면 CI 워크플로와 규칙 문서에서 찾아 씁니다. `pstack` 과 Codex CLI 가 있으면 적대 리뷰 후보를 더 모읍니다.

## spec-flow: 큰 기능을 만드는 순서

`pstack` 은 코드 구조를 정하고 검증하는 일을 맡지만 사용자에게 묻지 않도록 설계되어 있습니다. `spec-flow` 는 그 앞과 뒤를 맡습니다.

```
/make_spec <만들 기능>      이유와 제품 결정을 대화로 확인 → 스펙 승인 → 인계 문장 출력
/poteto-mode <인계 문장>    구조 설계 경합 → 설계와 계획 승인 → 구현 → 검증
run_final_check             드래프트 PR → 서브에이전트 리뷰 → 수정 → 게시 승인 → Ready
```

- `make_spec`: 프로젝트가 답하는 것은 묻지 않고 읽어서 확인합니다. 질문은 한 번에 하나씩 하고, 접근 방식은 동작 수준에서 두세 개를 제시합니다. 타입과 모듈 경계는 정하지 않고 `pstack` 의 `architect` 에 넘깁니다. 스펙은 사용자의 규칙이 정한 경로에 쓰고, 정한 경로가 없으면 묻습니다.
- 인계 문장: `make_spec` 이 승인 뒤에 출력합니다. 스펙의 결정을 바꾸지 않는다, 구현 전에 설계와 계획을 승인받는다, 끝나면 결정마다 지켰는지 표로 보고한다, 그 뒤 `run_final_check` 를 따른다는 줄이 들어 있습니다. 사용자가 `/poteto-mode` 에 직접 붙여 넣습니다.
- `run_final_check`: `/run_final_check` 로 따로 부를 수도 있습니다. PR 본문은 프로젝트의 PR 스킬로 쓰고, 리뷰는 프로젝트의 리뷰 스킬(`review-pr` 등)을 새 서브에이전트가 돌립니다. 리뷰 서브에이전트는 HTML 보고서 대신 항목 파일을 쓰고, 보고서는 메인 세션이 한 번만 발행합니다. 적대 검토자는 테스트와 생성 파일을 뺀 변경이 400줄 이상이거나 크리티컬 · 메이저 후보가 나왔을 때만 1명 띄웁니다. 수정 뒤의 재리뷰는 새 서브에이전트가 수정 diff 만 봅니다. 승인 전에 하는 외부 쓰기는 작업 브랜치 푸시와 드래프트 PR 생성(리뷰어와 멘션 없음)뿐입니다. 여러 PR 로 나눈 작업은 PR 을 하나씩 처리합니다.

두 스킬은 `disable-model-invocation` 으로 설정되어 있어서 자동으로 실행되지 않습니다.

### 설치와 필요한 것

`kang-setup` 번들에 들어 있습니다. 따로 설치하려면 다음을 실행합니다.

```
/plugin install spec-flow@team-plugins
```

- `pstack`: 필수입니다. 인계 문장이 `/poteto-mode` 와 `architect` 를 부릅니다.
- `gh`·`git`: `run_final_check` 가 드래프트 PR 을 만들고 게시할 때 씁니다.
- 프로젝트의 PR 스킬과 리뷰 스킬: 있으면 그것을 씁니다. 없으면 PR 템플릿과 `code-review` 를 씁니다. 이 마켓플레이스의 `review-pr` 을 리뷰 스킬로 쓸 수 있습니다.
- 스펙을 둘 경로: 자기 CLAUDE.md 에 한 줄로 적어 두면 매번 묻지 않습니다. 예: 「스펙과 계획은 `~/docs/design/` 에 둔다. 커밋하지 않는다.」

### 사용 순서

1. `/make_spec <만들 기능>` 을 실행합니다. 기능은 한 문장이면 됩니다.
2. 질문에 답합니다. 처음에는 이유를 묻고, 그 뒤에는 결정을 하나씩 묻습니다. 이해한 내용을 되돌려 말하면 틀린 부분을 고쳐 줍니다.
3. 제시된 접근 방식 중 하나를 고릅니다.
4. 스펙 파일을 읽고 승인합니다. 큰 작업이면 승인 전에 구현자 점검에서 나온 질문이 한 번 더 옵니다.
5. 출력된 인계 문장을 복사해서 그대로 입력합니다. `/poteto-mode` 로 시작하는 여러 줄입니다. 같은 세션이어도 되고 새 세션이어도 됩니다.
6. 구조 설계와 구현 계획이 나오면 읽고 승인합니다. 순서나 구조를 바꾸려면 이때 말합니다.
7. 구현, 검증, 드래프트 PR, 리뷰, 수정이 끝나면 한 번 멈춥니다. PR 본문, 고친 것, 남은 항목, 코멘트 초안을 확인하고 게시할 것을 승인합니다. 일부만 승인할 수 있습니다.
8. 승인한 코멘트가 게시되고, 리뷰어가 지정되고, PR 이 Ready 로 바뀝니다. 머지는 직접 합니다.

사용자가 승인하는 곳은 스펙(4), 설계와 계획(6), 게시(7) 세 번입니다.

### 상황별 사용

- **PR 없이 구현만 하려면**: 인계 문장의 마지막 줄(`run_final_check` 를 가리키는 줄)을 「푸시와 PR 은 하지 않는다」 로 바꿔서 입력합니다.
- **스펙 없이 만든 브랜치를 올리려면**: 작업 브랜치에서 `/run_final_check` 를 실행합니다. 버그 수정이나 리팩터링에 씁니다.
- **여러 PR 로 나누려면**: `make_spec` 이 작업 크기를 말할 때 그렇게 정하면, 인계 문장에 줄이 하나 더 붙습니다. 6번에서 PR 목록을 함께 승인하고, PR 마다 7~8번을 되풀이합니다. 앞 PR 의 게시를 승인한 뒤에 다음 PR 이 시작됩니다.
- **작은 변경**: `make_spec` 은 짧은 스펙을 쓰고 구현자 점검을 건너뜁니다. 원인이 알려진 버그 수정, 문서, 설정 변경에는 이 흐름을 쓰지 않아도 됩니다.

## 업데이트

- **수동**: `/plugin marketplace update team-plugins` 를 실행한 뒤 `claude plugin update <이름>@team-plugins` 를 실행하고, `/reload-plugins` 로 적용합니다. 번들에 새 플러그인이 추가됐으면 `claude plugin update kang-setup@team-plugins` 뒤 `/reload-plugins` 가 새 의존성을 설치합니다.
- **자동**: `/plugin` → Marketplaces → team-plugins → Enable auto-update 를 켭니다. 기본값은 꺼짐입니다.
- **버전 규칙**: `kang-setup`, `kang-rules`, `compact-handoff`, `make-notion`, `review-pr`, `spec-flow` 는 이 레포의 커밋이 곧 새 버전입니다. 스킬 플러그인 3개는 업스트림이 `version` 을 올릴 때 따라갑니다.
- **번들 제거**: `claude plugin uninstall kang-setup@team-plugins` 를 실행해도 의존성 플러그인은 남습니다. 의존성까지 전부 지우려면 `claude plugin prune` 을 실행합니다. 이 명령은 자동 설치된 플러그인(context7, notion, pstack, compact-handoff 포함)을 모두 지우므로, `--dry-run` 으로 먼저 확인합니다.

## 이미 설치한 사람

다른 마켓플레이스(`diagram-design`, `claude-community`, `cursor-plugins`)에서 같은 플러그인을 이미 설치했어도 그대로 두고 설치해도 됩니다. 두 개가 나란히 켜지고 스킬이 목록에 두 번 보일 뿐, 오류는 없습니다(실측: 두 플러그인의 스킬이 모두 로드되고 충돌 없음). 하나만 두고 싶으면 옛것을 지웁니다.

```sh
claude plugin uninstall diagram-design@diagram-design
```

## 라이선스

MIT
