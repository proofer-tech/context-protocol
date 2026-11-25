---
type: concept
scheme: context-protocol
pref_label_ko: 에이전트 하네스
pref_label_en: Agent harness
broader: "[[context-workspace]]"
related:
  - "[[storage-backend]]"
definition: 워크스페이스를 열어 읽고 쓰는 에이전트 실행 환경(Claude Code, Cowork, Codex, Cursor, Google Antigravity, Grok Build, 파일 업로드형 대화 등). 자동으로 읽는 진입 파일, 호스트 파일 도구, 자체 메모리, 마운트 성질이 하네스마다 다르다. 8.0 부터 코어는 그 차이를 하네스 프로파일로만 흡수한다.
updated: 2026-10-25
---

# 에이전트 하네스

[[storage-backend]] 와 짝을 이루는 개념이다. 백엔드는 WS 가 어디에 놓이는가를 다루고,
하네스는 누가 WS 를 여는가를 다룬다. 7.x 까지 하네스는 Claude Cowork 로 고정이었고,
그 가정이 코어 본문에 도구 이름(Desktop Commander, auto-memory), 진입 파일명(CLAUDE.md),
마운트 성질(Layer A)로 박혀 있었다. 8.0 은 이것들을 아래 능력 키로 바꾸고, 실제 도구
이름은 하네스별 프로파일 `_context-protocol/harnesses/<harness_id>.md` 에만 적는다.
8.0 의 설계와 실측 기록은 프로토콜 워크스페이스(context-protocol)의
`_context-protocol/harnesses/harness-portal-design.md` 에 있다.

## 진입 파일: 정본과 포털

- `CONTEXT.md`: 워크스페이스 루트의 규칙 정본이자 세션 진입점. frontmatter 에
  `ws_backend`, `ws_backend_source`, `ws_rel_path` 를 둔다.
- `AGENTS.md`, `CLAUDE.md`: 루트의 포털. 하네스가 스스로 읽는 파일이라서 둔다. 본문은
  CONTEXT.md 를 먼저 읽으라는 지시와 중첩 워크스페이스 규칙뿐이고 규칙을 담지 않는다.
  포털에 규칙이 생기면 정본이 둘로 갈라진다. 발견하면 CONTEXT.md 로 옮긴다.

어느 하네스가 어느 포털을 읽는지는 각 프로파일의 `entry_file` 에 있다. 포털 두 개는
늘 함께 둔다. 크기가 작고, 사용자가 도구를 바꿨을 때 아무것도 안 읽히는 사고를 막는다.

## 프로파일이 선언하는 능력

| 능력 키 | 값 | 좌우하는 코어 규칙 |
|---|---|---|
| `entry_file` | 하네스가 스스로 읽는 파일 / none | 어느 포털이 이 하네스를 정본으로 데려오는가 |
| `import_syntax` | 문법 / none | 포털이 정본 본문을 자동으로 끌어오는가. none 이면 에이전트가 CONTEXT.md 를 따로 읽는다 |
| `host_file_tool` | 도구 이름 | GUIDE §5. 호스트 파일의 검색, 읽기, 쓰기, 이동을 맡는 도구 |
| `proxy_mount` | yes / no | GUIDE §4.5 의 삭제, atomic rename, lockfile 금지(Layer A) |
| `agent_memory` | 이름과 위치 / none | GUIDE §2 의 L0, §6 의 override 대상 |
| `fs_write` | yes / no | no 면 GUIDE §12 축적이 열람 모드로 바뀐다 |
| `ask_tool` | 도구 이름 / none | 설치기와 인테이크 문답. none 이면 번호를 붙인 평문 질문 |
| `deliver_file` | 방법 | 산출물을 사용자에게 건네는 방법 |
| `bootstrap_block` | yes / no | 사람이 붙여넣는 지침 계층에 기대는가. 8.5 부터 설치할 수 있는 하네스는 모두 no 이고, 파일 진입점이 없는 `chat-upload` 만 yes 다 |

Layer A 는 7.x 에서 상수였다. 근거는 "세션에 연결된 폴더는 프록시 마운트를 지난다" 였는데,
그 전제가 Cowork 샌드박스에서만 참이라 8.0 에서 `proxy_mount` 로 옮겼다. 백엔드는 여전히
이 값을 끄지 못한다. 순수 로컬 디렉토리라도 Cowork 로 열면 삭제가 막힌다.

## 지금 있는 프로파일

| harness_id | 프로파일 | 상태 |
|---|---|---|
| `claude-cowork` | [[claude-cowork]] | 지원. 7.x 까지의 유일한 실측 대상 |
| `claude-code` | [[claude-code]] | 실측 통과 |
| `codex` | [[codex]] | 실측 통과(CLI, ChatGPT Work 모드) |
| `cursor` | [[cursor]] | 실측 통과 |
| `antigravity` | [[antigravity]] | 실측 통과(agy CLI) |
| `grok-build` | [[grok-build]] | 실측 통과(대화형). 헤드리스는 자동 로드 없음 |
| `chat-upload` | [[chat-upload]] | 열람 모드 전용. 미검증(실측 보류) |

## 하네스 판별

세션 시작에 백엔드보다 먼저, 정확히 한 번 판별한다. 백엔드 판별의 입력인 워크스페이스
경로가 하네스에 달려 있어서다. Cowork 는 연결된 폴더를 주고, 호스트에서 도는 하네스는
작업 디렉토리에서 가장 가까운 포털의 폴더가 WS 다.

1. 자기 런타임과 도구 목록으로 판별한다. 시스템 지시에 제품 이름이 있으면 그것을 쓴다.
   어느 포털을 받았는지로 판별하지 않는다. 여러 하네스가 같은 AGENTS.md 를 읽고,
   Grok Build 는 포털 두 개를 다 읽는다.
2. `_context-protocol/harnesses/<harness_id>.md` 를 읽는다. 그 파일만 읽는다. 다른
   프로파일의 도구 이름은 이 세션에 없다.
3. 맞는 프로파일이 없으면 아래 `generic` 폴백을 쓰고, 미검증 하네스라는 사실을 사용자에게
   한 번 알린다.
4. 결과는 이 세션에서만 쓰고 워크스페이스에 기록하지 않는다. 같은 워크스페이스를 오늘은
   Cowork, 내일은 Codex 로 열 수 있다. 백엔드와 달리 하네스는 워크스페이스의 성질이 아니다.

## 중첩 워크스페이스

Codex, Cursor, Claude Code, Grok Build 는 상위 폴더의 진입 파일도 읽는다. 워크스페이스 안에
다른 워크스페이스가 있으면 포털 두 개가 한 세션에 들어온다. 작업 디렉토리에서 가장 가까운
포털의 워크스페이스가 이 세션의 WS 다. 바깥 워크스페이스는 WS 가 아니라 import 후보다
(GUIDE §11). 포털 본문에 이 규칙을 적어 두는 이유다.

## 프로파일이 없는 하네스 폴백

```
entry_file: AGENTS.md        (포털이 둘이면 이쪽을 읽었다고 가정)
import_syntax: none          (CONTEXT.md 를 직접 읽는다)
host_file_tool: 자체 파일 도구와 셸
proxy_mount: yes             (안전한 쪽. 마운트 위에서 삭제, git, 임시 파일을 하지 않는다)
agent_memory: 있다고 가정    (안전한 쪽. 자체 메모리에 본문을 두지 않는다)
fs_write: 실제로 써 보고 판정
ask_tool: none
deliver_file: 워크스페이스 경로 보고
bootstrap_block: no
```

보수적이라는 말은 백엔드 폴백과 같이 "제약을 더 거는 쪽" 이라는 뜻이다.

## 새 하네스를 추가할 때

1. `_context-protocol/harnesses/<harness_id>.md` 를 만든다. 아홉 개 능력 키를 전부 채우고,
   값마다 근거가 실측인지 문서인지 추측인지 적는다.
2. GUIDE 는 건드리지 않는다. 하네스 추가가 코어 개정을 요구하면 그 지점이 코어의 추상화
   누수다.
3. 이 노트의 프로파일 목록 표에 행을 추가한다. 새 진입 파일이 필요하면 포털을 추가하되
   본문 규약(위 "진입 파일")을 지킨다.
4. `_project.md` 의 `suitability.subjects` 확인, action-log 엔트리.

## 무엇을 하네스 문제로 보지 말아야 하나

아래는 하네스와 무관하다. 프로파일에 적지 않는다.

- 지연 하이드레이션, 네이티브 문서 스텁, 동기화 지연(백엔드, `backends/`)
- macOS 의 NFC/NFD 경로 불일치(OS, GUIDE §4.4)
- 레이어 모델과 조회 순서, 쓰기 프로토콜, 온톨로지, 능동 축적 전체
