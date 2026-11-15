---
type: document
subject:
  - "[[agent-harness]]"
status: 배포
target_version: "8.0"
updated: 2026-10-29
---

# 하네스 중립화 설계 (8.0)

## 계기

교육 참가자에게서 "프로토콜이 CLAUDE.md 로 되어 있어 범용성이 떨어진다" 는 피드백이
왔다. 참가자는 `dist/` 의 zip 패키지로 설치한 사람들이다. 그래서 이번 개정은 배포
패키지를 먼저 맞추고, 설치본 전파(fleet)는 그 뒤에 한다.

## 진단

파일명은 증상이다. 7.3 정본에서 Claude 종속은 세 층에 걸쳐 있다.

1. 진입 파일명. 설치기가 `<claude_md>` 블록으로 대상 폴더에 CLAUDE.md 를 쓰고, 가이드가
   CLAUDE.md 를 규칙 정본으로 부른다(GUIDE §0, §4.9, §10 등). 백엔드 판별의 1순위
   근거도 CLAUDE.md frontmatter 다(storage-backend.md).
2. 도구 이름. 가이드 머리말이 Desktop Commander 를 전제 조건으로 걸고, §5 가 로컬
   작업 전부를 DC 로 표준화한다. §6 의 auto-memory override 는 Claude 의 호스트 메모리
   디렉토리를 겨냥한다.
3. 실행 환경. storage-backend.md 는 Layer A(삭제와 rename-over 를 거부하는 프록시
   마운트)를 "능력이 아니라 상수" 로 둔다. 근거는 "세션에 연결된 폴더는 프록시 마운트를
   지난다" 인데, 이 전제는 Cowork 샌드박스에서만 참이다. Claude Code CLI, Codex CLI,
   Cursor 는 호스트 파일시스템에서 직접 돌아 삭제와 git 이 된다. 7.x 는 하네스 조건을
   불변 규칙으로 적은 셈이다. "붙여넣은 지침 블록은 부트스트랩 포인터" 라는 5.0 구조도
   Claude 프로젝트 기능을 전제로 한다.

진입 파일만 AGENTS.md 로 바꾸면 Codex 가 파일을 읽기는 하지만, 읽은 뒤 "Desktop
Commander 로 작업하라", "auto-memory 를 override 하라" 는 지시를 받게 된다. 수행할 수
없는 지시다.

## 확정 (2026-10-25 임한솔)

- 범위: 하네스 프로파일을 도입하는 MAJOR 8.0.
- 구조: 공용 지침을 두고, 각 에이전트 스펙 파일은 공용 지침으로 들어가는 포털로 둔다.
  특정 LLM 스펙에 맞추지 않는다(임한솔 제안).
- 대상 하네스: Codex, Cursor, Google Antigravity, 파일 업로드형 대화. 기존 Claude Code
  와 Cowork 는 유지.
- 피드백 출처: 교육 참가자.
- 공용 지침 파일명: 루트의 `CONTEXT.md`.
- 검증 하네스: 맥에 Codex, Cursor, Google Antigravity, Grok Build 가 있다. 이 넷과 Claude Code, Cowork 로 실측한다.
- 이미 7.x 를 설치한 참가자에게는 MIGRATE 로 안내한다(새 zip 첨부 후 업데이트 요청).

## 외부 사실 (2026-10-25 조회)

| 하네스 | 자동으로 읽는 진입 파일 | 다른 파일 끌어오기 | 비고 |
|---|---|---|---|
| Claude Code | CLAUDE.md. 2.1.277(2026-09-18)부터 CLAUDE.md 가 없는 폴더에서는 AGENTS.md | `@경로` | 둘 다 있으면 CLAUDE.md. AGENTS.md 대체 읽기는 /config 에서 끌 수 있다 |
| Cowork | 연결 폴더의 CLAUDE.md, 붙여넣은 프로젝트 지침 | 미확인 | 2026-10-25 세션 관측: 연결 폴더 CLAUDE.md 가 프로젝트 지침으로 주입됐다. AGENTS.md 를 읽는지는 미확인 |
| Codex | AGENTS.override.md, AGENTS.md, 설정의 fallback 파일명 | 문서에 없음 | 프로젝트 루트(보통 git 루트)부터 현재 폴더까지 이어 붙이고 가까운 쪽이 뒤에 온다. 합계 32 KiB 상한(`project_doc_max_bytes`) |
| Cursor | 루트와 하위 폴더의 AGENTS.md, `.cursor/rules/*.mdc` | 문서에 없음 | 하위 폴더 AGENTS.md 는 상위와 합쳐지고 가까운 쪽이 우선 |
| Google Antigravity | AGENTS.md(IDE 1.20.5 부터), GEMINI.md, `.agents/rules` | 미확인 | 둘 다 있을 때 우선순위는 문서에 없다. 근거가 서드파티 글(2026-08-05)이라 실측 필요 |
| Grok Build | 루트부터 작업 폴더까지의 AGENTS.md, `.grok/rules/`, 호환용 CLAUDE.md | 문서에 없음 | 포털 두 개를 다 읽는다. `--experimental-memory` 로 세션 간 메모리를 켠다 |
| 파일 업로드형 대화 | 없음 | 없음 | 프로젝트 지침 붙여넣기와 첨부 파일만 |

출처: [Simon Willison 2026-09-18](https://simonwillison.net/2026/Sep/18/thariq-shihipar/),
[TabNews](https://www.tabnews.com.br/AndreiAlves/claude-code-agora-vai-ler-o-agents-md-finalmente),
[OpenAI Codex AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[Cursor Rules](https://cursor.com/docs/rules),
[Antigravity AGENTS.md guide](https://thepromptshelf.dev/blog/google-antigravity-agents-md-rules-guide-2026),
[innFactory Grok CLI](https://innfactory.ai/en/ai-harness/grok-cli/),
[DataCamp Grok Build tutorial](https://www.datacamp.com/tutorial/grok-build-tutorial)

자동 로드 기준으로 보면 AGENTS.md 포털이 Codex, Cursor, Antigravity, Grok Build 를 덮고, Claude
계열에는 CLAUDE.md 포털이 필요하다. Antigravity 가 AGENTS.md 를 읽는 한 GEMINI.md
포털은 두지 않는다.

## 제안 (채택 전)

### 1. 공용 지침, 포털, 하네스 프로파일

- 공용 지침: 워크스페이스별 운영 정본. 지금 CLAUDE.md 본문이 그대로 옮겨 온다
  (frontmatter 의 `ws_backend` 와 `ws_rel_path`, 세션 진입 순서, 필수 룰, 프로젝트 고유
  규칙). 파일명 제안은 루트의 `CONTEXT.md`.
- 포털: 루트의 `AGENTS.md` 와 `CLAUDE.md`. 본문은 "다른 일을 하기 전에 CONTEXT.md 를
  읽는다" 는 지시와 중첩 워크스페이스 규칙(아래 5)뿐이고 규칙을 담지 않는다. 포털에
  규칙을 담으면 정본이 둘이 되어, 5.0 이전에 지침 블록과 CLAUDE.md 사이에서 겪은
  분기가 다시 생긴다.
  - CLAUDE.md 포털은 `@CONTEXT.md` 로 본문을 자동으로 끌어온다(Claude Code). Cowork
    에서도 풀리는지는 실측한다. 안 풀리면 Cowork 쪽은 읽기 지시만으로 간다.
  - AGENTS.md 포털은 끌어오기 문법이 없어 에이전트가 파일을 한 번 더 읽어야 한다.
    포털 지시를 따르지 않는 모델이면 규칙이 통째로 빠진다. 지금도 붙여넣은 지침
    블록에서 CLAUDE.md 로 넘어가는 같은 단계에 기대고 있어 새로운 위험은 아니지만,
    검증 항목에 넣는다.
  - 검토한 대안: AGENTS.md 를 공용 지침으로 쓰고 CLAUDE.md 만 포털로 둔다. Codex,
    Cursor, Antigravity 에서 한 단계가 사라진다. 대신 AGENTS.md 스펙의 변화(override
    파일, 하위 폴더 병합, 크기 상한)를 프로토콜이 따라가야 하고, 정본을 특정 스펙에
    맡기게 되어 확정된 구조와 어긋난다. 그래서 중립 정본을 권한다.
- 하네스 프로파일: `_context-protocol/harnesses/<harness_id>.md`. 코어가 쓰는 능력어를
  그 하네스의 실제 도구 이름에 묶는다. 백엔드 프로파일과 같은 방식이다.

### 2. 능력 계약 (안)

| 능력 키 | 값 | 좌우하는 코어 규칙 |
|---|---|---|
| `entry_file` | CLAUDE.md / AGENTS.md / none | 설치기가 쓰는 포털 |
| `import_syntax` | 문법 / none | 포털이 정본을 자동으로 끌어오는지 |
| `host_file_tool` | 도구 이름 / native | GUIDE §5. Cowork 는 Desktop Commander, 호스트에서 직접 도는 하네스는 자체 셸과 파일 도구 |
| `proxy_mount` | yes / no | GUIDE §4.5 의 삭제, atomic rename, lockfile 금지. 7.x 의 Layer A 상수를 이 키로 옮긴다 |
| `agent_memory` | 이름과 위치 / none | GUIDE §6 override 대상. Claude 의 auto-memory 처럼 하네스가 따로 갖는 메모리 |
| `fs_write` | yes / no | no 면 축적 규칙이 열람 모드로 바뀐다(아래 4) |
| `ask_tool` | 도구 이름 / none | 설치기와 인테이크 문답. none 이면 번호를 붙인 평문 질문 |
| `deliver_file` | 방법 | 산출물 전달. 채팅 첨부, 워크스페이스 경로 보고 등 |
| `bootstrap_block` | yes / no | 붙여넣는 지침 블록 계층(5.0 역전)이 있는지 |

프로파일이 없는 하네스는 `generic` 폴백을 쓴다. `proxy_mount: yes` 로 가정하고,
`fs_write` 는 실제로 써 보고 판정하고, `ask_tool: none` 으로 둔다. 모르면 안전한 쪽을
고르는 백엔드 폴백과 같은 원리다.

### 3. 판별 순서

하네스 판별을 백엔드 판별보다 먼저 한다. 백엔드 판별의 입력인 "연결된 경로" 가 하네스에
따라 다르기 때문이다(Cowork 는 연결 폴더, Codex 와 Cursor 는 작업 디렉토리).

여러 하네스가 같은 AGENTS.md 를 읽으므로 포털은 하네스를 선언할 수 없다. 에이전트가
자기 도구 목록으로 판별한다. 결과는 세션 안에서만 쓰고 워크스페이스에 기록하지 않는다.
같은 워크스페이스를 오늘은 Cowork, 내일은 Codex 로 열 수 있어서다.

### 4. 파일 업로드형 대화

`fs_write: no` 다. 프로토콜의 중심인 능동 축적이 동작하지 않으므로 정식 지원으로 두지
않고 열람 모드로 둔다. 첨부된 정본과 MEMORY 인덱스로 조회만 하고, 기록할 사실이 생기면
넣을 경로와 본문을 사용자에게 건네 사람이 반영한다. 패키지에 이 모드용 붙여넣기
지침을 따로 넣고, README 에서 이 제약을 미리 밝힌다.

### 5. 중첩 워크스페이스

Codex 와 Cursor 는 상위 폴더의 AGENTS.md 를 하위 것과 합친다. Claude Code 도 상위
CLAUDE.md 를 읽는다. 팀 프루퍼 안의 `프로젝트/context-protocol` 처럼 워크스페이스가
중첩되면 포털 두 개가 한 세션에 같이 들어온다. 가이드와 `_ontology.md` 에서 이 경우의
규칙을 찾지 못했다. 8.0 포털 본문에 "작업 디렉토리에서 가장 가까운 포털의 워크스페이스가
이 세션의 WS 다" 를 넣는다.

### 6. 정본 개정 범위

- `CONTEXT_GUIDE.md`: 머리말 전제 조건, §0 의 Layer A 서술, §0-A 앞 하네스 판별, §4.5 를
  `proxy_mount` 로 게이팅, §5 를 `host_file_tool` 로, §6 override 를 `agent_memory` 로,
  §4.9 와 §10 의 CLAUDE.md 언급을 정본 파일로.
- `backends/storage-backend.md`: Layer A 상수 문단, 판별 근거 표의 위치.
- `_ontology.md`: 레이아웃에 `CONTEXT.md`, `AGENTS.md`, `harnesses/`. 레이아웃 버전 8.0.
- `_schema/concept-scheme.md`: `harness_id` 술어(프로파일 파일명과 같아야 한다).
- `installers/CONTEXT_SETUP.md`: `<claude_md>` 를 `<context_md>`, `<portal_agents_md>`,
  `<portal_claude_md>`, `<harness_profiles>` 로 나눈다. 포털 두 개는 늘 쓴다. 크기가
  작고, 참가자가 도구를 바꿨을 때 아무것도 안 읽히는 사고를 막는다. 비개발자 참가자에게
  도구를 묻는 문항도 줄어든다.
- `installers/CONTEXT_MIGRATE.md`: 7.x 에서 8.0 델타. CLAUDE.md 본문으로 CONTEXT.md 를
  새로 쓰고 해시를 대조한 뒤 CLAUDE.md 를 포털로 덮어쓴다. rename 이 아니라 쓰기 두
  번이라 마운트에서도 된다. 붙여넣은 지침 블록은 CLAUDE.md 를 가리키고 포털이 정본으로
  이어 주므로 다시 붙여넣지 않아도 된다.
- 패키지 README: 하네스 중립 문구, 도구별 첫 실행 방법, 업로드형 열람 모드 안내.
- `dist/protocol-build.md`: 수록표와 제외표.
- 7.3 은 아직 빌드되지 않았다. 8.0 빌드가 7.3 변경을 함께 싣는다.

### 7. 검증 계획

6.1 처럼 문서를 실제로 실행해 본다.

- Claude Code: 신규 설치, `@CONTEXT.md` 해석.
- Cowork: CLAUDE.md 포털의 끌어오기가 풀리는지.
- Codex: AGENTS.md 포털에서 정본까지 따라가는지, git 루트가 없는 폴더에서 AGENTS.md 를 읽는지.
- Cursor 와 Antigravity: AGENTS.md 포털, Antigravity 는 GEMINI.md 와 같이 있을 때의 동작.
- MIGRATE: 7.2 설치본 사본에 적용.
- 업로드형: 붙여넣기 지침과 첨부만으로 조회가 되는지.

### 8. 실측 결과 (2026-10-25, 이 워크스페이스)

같은 질문(자동 로드된 지시 파일, 읽은 순서, 하네스 판별, 백엔드, git 과 삭제 허용 여부, 못 따른 지시)을
읽기 전용 모드로 던졌다.

| 하네스 | 결과 |
|---|---|
| Claude Code 2.1.295 | 통과. 포털 CLAUDE.md 와 `@CONTEXT.md` 본문이 자동 로드. frontmatter 는 import 에서 빠져 머리를 따로 읽었다. 상위 팀 프루퍼 CLAUDE.md 도 로드됐지만 중첩 규칙대로 바깥을 import 후보로 두었다. 하네스 `claude-code`, 백엔드 `gdrive` |
| ChatGPT Work 모드(폴더 지정) | 통과(임한솔 실행). Codex desktop 런타임으로 판별, AGENTS.md 자동 로드, 하네스 `codex`, 백엔드 `gdrive`, git 금지 |
| Codex 0.160.0 | 통과. git 루트 없는 폴더에서 AGENTS.md 자동 로드, 포털을 따라 CONTEXT.md 로. 하네스 `codex`, 백엔드 `gdrive`. 읽기 전용이라 `fs_write: no` 로 판정 |
| Cowork (클라우드) | 통과. CLAUDE.md 포털이 주입됐고 `@CONTEXT.md` 는 풀리지 않았지만 포털의 읽기 지시로 정본에 들어갔다. 하네스 `claude-cowork`, 백엔드 `gdrive`, 삭제와 git 모두 금지로 맞게 답했다. 프로파일의 `host_file_tool` 이 데스크톱 로컬만 전제한 점을 짚어 실행 형태 절을 더했다 |
| Grok Build 1.0.70 대화형 | 통과(임한솔 실행). AGENTS.md 와 CLAUDE.md 포털이 모두 자동 로드, import 는 안 풀림. 하네스 `grok-build`, 백엔드 `gdrive`, git 금지와 삭제 허용 모두 규칙대로 |
| Grok Build 1.0.70 헤드리스 | 부분 통과. 자동 로드된 지시 파일이 없었다(헤드리스, 비 git 폴더). 루트를 훑어 CONTEXT.md 를 찾아 진입했고 하네스 `grok-build`, 백엔드 `gdrive` 는 맞았다. git 허용 여부를 `proxy_mount` 만 보고 '허용' 이라 답했다. 0.2.118 은 서버가 426 으로 거부해 `grok update` 로 올렸다 |
| Cursor Agent CLI 2026.01.23 | 통과. AGENTS.md 와 CLAUDE.md 포털이 모두 자동 로드(상위 CLAUDE.md 포함). 중첩 규칙, 하네스 `cursor`, 백엔드 `gdrive`, git 금지 모두 맞았다 |
| Antigravity CLI(agy) 1.4.7 | 통과. AGENTS.md 만 자동 로드. 포털을 따라 정본으로, 하네스 `antigravity`, 백엔드 `gdrive`, git 금지 모두 맞았다. 헤드리스는 `--dangerously-skip-permissions` 가 있어야 돈다 |

실측이 드러낸 결함과 조치:

- 정본 1번의 "follow every index hit" 를 두 하네스가 "모든 본문을 읽어야 하느냐" 로 읽었다.
  세션 시작에 전부 읽을 필요는 없고 요청이 닿는 항목만 따라간다고 고쳐 썼다. 설치기 템플릿에도 넣는다.
- `@` import 는 frontmatter 를 싣지 않는다. 백엔드 키가 frontmatter 에 있으므로 CLAUDE.md 포털에
  "머리만 따로 읽는다" 를 적었다.
- 동기화 폴더 안 git 금지가 GUIDE §4.5 의 권고와 claude-code 프로파일 주의에만 있었다. Grok 이 이를 놓쳤다.
  백엔드 사정이므로 `backends/gdrive.md` 의 규칙으로 올렸다. 설치기 `<backend_profiles>` 에도 넣는다.

### 8-1. 팀 프루퍼 적용 실측 (2026-10-26, 임한솔 요청)

팀 프루퍼(7.2)를 손으로 8.0 으로 올리고 루트에서 같은 질문을 던졌다. MIGRATE 설치기 없이 한 첫 실제
워크스페이스 적용이라 MIGRATE 8.0 델타의 시연이기도 하다.

- Claude Code, Codex, Antigravity CLI 통과. Cursor 는 인증 만료로 미실행.
- 팀 프루퍼 `backends/gdrive.md` 에만 있던 Windows find 실측 절(2026-10-13)이 정본에 없었다. 정본으로
  되돌려 넣었다. MIGRATE 는 백엔드 프로파일을 통째로 덮으면 이런 현장 실측을 지운다. 8.0 MIGRATE 는 프로파일을
  덮기 전에 정본에 없는 절을 찾아 보고해야 한다.
- 팀 프루퍼의 한글 운영 문서 `memory/context_protocol.md` 는 설치기가 만든 파일이 아니라 MIGRATE 가 모른다.
  7.x 진입점 문구가 남아 Claude Code 가 짚었다. 설치본마다 이런 파생 문서가 있을 수 있으므로 MIGRATE 8.0 은
  워크스페이스 전체에서 `CLAUDE.md frontmatter` 같은 옛 진입점 표현을 검색해 보고하는 단계를 둔다.

### 9. 진행

- [x] 설계와 열린 질문 정리(2026-10-25)
- [x] 정본 개정: 하네스 계약과 프로파일 7종, GUIDE 8.0(§0-B 신설, §0, §2, §3, §3-A, §4, §5, §6, §8, §9, §10, §11, §12), storage-backend, local, gdrive, `_ontology.md` 레이아웃 v8.0, concept-scheme `harness_id`, 이 워크스페이스 자신의 진입 파일(CONTEXT.md + 포털 두 개)(2026-10-25)
- [x] 설치기 SETUP 과 MIGRATE(2026-10-29). 7.3 레지스트리 행도 함께 넣었다
- [x] 포털 실측: Claude Code, Codex, Cursor, Antigravity 통과, Grok Build 부분 통과(자동 로드 없음)(2026-10-25)
- [x] Cowork 포털 실측 통과, import 는 안 풀린다(2026-10-25)
- [x] Grok 대화형 실측 통과(2026-10-25)
- [ ] 남은 실측: 쓰기 모드의 `proxy_mount`, MIGRATE, 업로드형은 보류(임한솔 결정 2026-10-25: 정식 포함 결정 뒤, ChatGPT 가 Work 모드로 폴더를 열 수 있음이 확인돼 실측 보류. 프로파일은 미검증으로 남김)
- [x] 8.0 빌드와 README(2026-10-29, `dist/context-protocol-8.0.zip`). 빌드 전 설치기 시뮬레이션 두 개(Codex 신규 설치, 7.2 에서 8.0 MIGRATE)로 결함 11종을 고쳤고, 프리셋의 CLAUDE.md 지칭을 CONTEXT.md 로 바꿨다
- [x] 설치본 전파(fleet): 8곳 8.0, PPB 두 곳은 드라이브 읽기 타임아웃으로 보류(2026-10-26). 설치기 개정과 빌드보다 먼저 했다
