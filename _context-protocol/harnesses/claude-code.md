---
type: document
harness_id: claude-code
title: Harness profile - Claude Code
updated: 2026-10-25
---

# 하네스 프로파일: Claude Code

터미널의 Claude Code CLI 와 IDE 확장. 호스트 파일시스템에서 직접 돈다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | CLAUDE.md (작업 폴더와 상위 폴더). CLAUDE.md 가 없는 폴더에서는 AGENTS.md | 실측(2.1.295, 2026-10-25): 작업 폴더 포털과 상위 팀 프루퍼 CLAUDE.md, 사용자 전역 CLAUDE.md 가 함께 들어왔다. AGENTS.md 대체 읽기는 문서(2.1.277 부터, /config 에서 끌 수 있다) |
| `import_syntax` | `@경로` | 실측(2026-10-25): 포털의 `@CONTEXT.md` 가 본문을 끌어왔다. frontmatter 는 빠진다 |
| `host_file_tool` | 내장 Read, Write, Edit, Grep, Glob 과 Bash | |
| `proxy_mount` | no | 추측. 호스트에서 직접 돌아 마운트 계층이 없다. 샌드박스 설정을 켰을 때의 삭제 동작은 실측 대상 |
| `agent_memory` | 호스트 auto-memory 디렉토리 | |
| `fs_write` | yes | |
| `ask_tool` | AskUserQuestion | |
| `deliver_file` | 워크스페이스 경로 보고 | |
| `bootstrap_block` | no | |

## 주의

- 포털 CLAUDE.md 의 `@CONTEXT.md` 가 정본 본문을 끌어온다. frontmatter 는 끌려오지 않으므로
  백엔드 키(`ws_backend` 등)는 CONTEXT.md 머리만 따로 읽는다. 포털 본문이 그렇게 지시한다.
- 중첩 워크스페이스 규칙이 실측에서 동작했다. 상위 팀 프루퍼 CLAUDE.md 가 같이 로드됐지만
  가장 가까운 포털의 워크스페이스를 WS 로 잡고 바깥은 import 후보로 두었다.
- `proxy_mount: no` 라도 클라우드 동기화 폴더 안에서 git 저장소를 운용하지 않는다. 동기화
  클라이언트와 `.git` 내부 파일이 충돌한다. 이것은 백엔드 쪽 사정이다.
