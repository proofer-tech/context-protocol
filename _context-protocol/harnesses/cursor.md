---
type: document
harness_id: cursor
title: Harness profile - Cursor
updated: 2026-10-25
---

# 하네스 프로파일: Cursor

Cursor 에디터의 에이전트. 호스트 파일시스템에서 돈다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | AGENTS.md (루트와 하위 폴더), CLAUDE.md, `.cursor/rules/*.mdc` | 실측(Cursor Agent CLI 2026.01.23, 2026-10-25): 작업 폴더의 AGENTS.md 와 CLAUDE.md 포털, 상위 팀 프루퍼 CLAUDE.md, 사용자 홈 CLAUDE.md 가 함께 로드됐다. 문서: 하위 폴더 AGENTS.md 는 상위와 합쳐지고 가까운 쪽이 우선한다. `.cursor/rules` 안의 일반 `.md` 는 무시된다 |
| `import_syntax` | none | 문서에 없음 |
| `host_file_tool` | 내장 파일 편집과 터미널 | |
| `proxy_mount` | no | 추측. 쓰기 실측 대상 |
| `agent_memory` | Cursor Memories | 문서에 기능이 있다. 동작은 실측 대상 |
| `fs_write` | yes | |
| `ask_tool` | 미확인 | 없으면 평문 질문 |
| `deliver_file` | 워크스페이스 경로 보고 | |
| `bootstrap_block` | no. 사용자 규칙(User Rules) 계층은 있다 | |

## 주의

- 실측에서 포털을 따라 CONTEXT.md, MEMORY.md, `cursor.md`, `gdrive.md` 순으로 읽고 하네스 `cursor`,
  백엔드 `gdrive` 로 맞게 판별했다. 상위 팀 프루퍼 CLAUDE.md 는 중첩 규칙대로 import 후보로 두었고,
  git 은 `gdrive.md` 규칙으로 금지라고 답했다.
- 이 맥에서 Cursor CLI 명령은 `cursor-agent` 다. `agent` 는 Grok 실행 파일로 연결되어 있다.

- 프로토콜용 `.cursor/rules` 파일을 만들지 않는다. AGENTS.md 포털로 충분하고, 점 폴더는
  Obsidian 과 검색 도구가 건너뛴다(GUIDE §10).
