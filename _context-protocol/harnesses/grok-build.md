---
type: document
harness_id: grok-build
title: Harness profile - Grok Build
updated: 2026-10-25
---

# 하네스 프로파일: Grok Build

xAI 의 Grok Build(Grok CLI). 호스트 파일시스템에서 돈다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | 문서상 루트부터 작업 폴더까지의 AGENTS.md, `.grok/rules/`, 호환용 CLAUDE.md | 서드파티 문서(2026-09-20 갱신). 실측(1.0.70, 2026-10-25, `-p` 헤드리스, git 저장소가 아닌 드라이브 폴더): 자동 로드된 지시 파일이 없었다. 루트를 나열하고 CONTEXT.md 와 포털을 스스로 찾아 읽었다. 실측(1.0.70 대화형, 2026-10-25, 같은 폴더): AGENTS.md 와 CLAUDE.md 포털이 둘 다 자동 로드됐다(파일명을 `Agents.md`, `Claude.md` 로 표기). 자동 로드는 대화형에서만 일어나고 `-p` 헤드리스에서는 일어나지 않는다 |
| `import_syntax` | none | 실측(대화형): CLAUDE.md 포털의 `@CONTEXT.md` 가 풀리지 않았다. 포털의 읽기 지시로 정본에 들어갔다 |
| `host_file_tool` | 자체 파일 도구와 셸 | |
| `proxy_mount` | no | 추측. 실측 대상 |
| `agent_memory` | `--experimental-memory` 로 켜는 세션 간 메모리(`/remember`, `/memory`) | 서드파티 문서(2026-07-23) |
| `fs_write` | yes. 기본은 Ask 모드라 쓰기마다 승인을 묻는다 | |
| `ask_tool` | 미확인 | 없으면 평문 질문 |
| `deliver_file` | 워크스페이스 경로 보고 | |
| `bootstrap_block` | no | |

## 주의

- 문서대로라면 포털 두 개를 다 읽는다. 둘 다 CONTEXT.md 를 가리키므로 해가 없다. 포털에 규칙을
  넣으면 여기서 두 번 적용되거나 서로 어긋난다.
- 대화형 실측에서 포털 두 개가 다 로드됐고 CONTEXT.md, MEMORY.md, `grok-build.md`, `gdrive.md` 순으로
  읽었다. 하네스 `grok-build`, 백엔드 `gdrive`, git 은 `gdrive.md` 규칙으로 금지, 삭제는 `proxy_mount: no`
  로 허용이라고 맞게 답했다.
- `-p` 헤드리스 실측에서는 자동 로드가 없었고 에이전트가 루트를 훑어 정본을 찾았다. 스크립트로 Grok 을
  돌릴 때는 프롬프트에 "CONTEXT.md 를 먼저 읽어라" 를 넣는다.
- 0.2.x CLI 는 서버가 거부한다(426, 1.0.13 이상 요구). 설치 안내에 `grok update` 를 넣는다.
- 메모리를 켜고 쓰면 `/remember` 로 저장한 내용이 L0 다. 본문은 `memory/` 에 둔다(GUIDE §6).
