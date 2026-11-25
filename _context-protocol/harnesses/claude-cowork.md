---
type: document
harness_id: claude-cowork
title: Harness profile - Claude Cowork
updated: 2026-11-25
---

# 하네스 프로파일: Claude Cowork

Claude 데스크톱 앱의 Cowork 모드. 에이전트는 샌드박스에서 돌고, 사용자가 연결한 폴더가
샌드박스 안으로 마운트된다. 7.x 프로토콜은 이 하네스 하나를 전제로 쓰였다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | CLAUDE.md (연결 폴더 루트) | 실측(2026-10-25, 클라우드 Cowork): 연결 폴더의 CLAUDE.md 포털이 프로젝트 지침으로 주입됐고, 포털 지시를 따라 CONTEXT.md 로 들어갔다 |
| `import_syntax` | none | 실측(2026-10-25): 포털의 `@CONTEXT.md` 가 풀리지 않았다. 포털의 읽기 지시로 정본에 닿았다 |
| `host_file_tool` | 실행 형태에 따라 다르다. 아래 "실행 형태" 절 | 데스크톱 로컬은 실측(5.0 이후), 클라우드는 실측(2026-10-25) |
| `proxy_mount` | yes | 실측. 연결 폴더면 클라우드든 로컬이든 unlink 와 rename-over 가 거부된다 |
| `agent_memory` | 호스트 auto-memory 디렉토리. claude.ai 계정 메모리가 붙는 경우도 있다 | 실측 |
| `fs_write` | yes | |
| `ask_tool` | AskUserQuestion | |
| `deliver_file` | 워크스페이스의 개념 폴더에 직접 쓰고 경로를 보고한다(8.6). 채팅 첨부(SendUserFile)는 사용자가 요청할 때만 주는 사본이다 | 2026-11-25 관측: 채팅 첨부가 연결 폴더 루트의 `Claude outputs/` 에 쌓여 어느 개념 폴더에도 속하지 않았다 |
| `bootstrap_block` | no. 8.4 까지는 yes(프로젝트 지침 붙여넣기) | 실측(2026-10-25, 클라우드 Cowork)과 2026-11-25 세션 관측: 연결 폴더의 CLAUDE.md 포털이 프로젝트 지침으로 주입되어 붙여넣은 블록 없이 CONTEXT.md 에 닿는다. 8.5 에서 붙여넣기를 없앴다. 데스크톱 로컬 Cowork 는 아직 따로 실측하지 않았다 |

## 실행 형태

Cowork 는 에이전트가 어디서 도느냐에 따라 호스트 측 도구가 갈린다. 세션은 자기 도구 목록으로 구별한다.

- 데스크톱 로컬 Cowork: 에이전트가 사용자 PC 의 샌드박스에서 돈다. 호스트 측 도구는 Desktop Commander 이고,
  내장 Read, Grep, Glob 도 호스트 측에서 돈다.
- 클라우드 Cowork(사용자 PC 와 연결된 세션, `mcp__remote-devices__*` 도구가 있다): 에이전트가 클라우드
  컨테이너에서 돈다. 내장 Read, Grep, Glob, Bash 는 클라우드 컨테이너만 본다. 그래서 내장 도구의 빈 검색
  결과는 워크스페이스에 없다는 증거가 못 된다(GUIDE §3-A). 연결 폴더는 `device_bash`(사용자 PC 의 VM 에
  `$HOME/mnt/<폴더>` 로 마운트, 삭제는 사용자 승인 전까지 거부)로 읽고 쓴다. Desktop Commander 가 연결돼
  있으면 macOS 호스트에서 직접 돌아 클라우드 전용 파일을 하이드레이션하므로, 읽기가 deadlock 을 내면
  DC 로 넘어간다. 연결 폴더 파일을 채팅에 붙일 때는 스테이징한 뒤 첨부한다.

어느 형태든 연결 폴더 경로는 프록시 마운트를 지나므로 `proxy_mount: yes` 다.

## Desktop Commander 작업 대응

- 검색: `start_search` (searchType=files/content)
- 읽기: `read_file` / `read_multiple_files`
- 쓰기: `write_file` (25~30 줄 단위), 편집: `edit_block`
- 폴더: `list_directory`, `move_file`, `create_directory`
- 셸: `start_process` / `interact_with_process`

DC 는 호스트에서 격리 없이 돈다. 삭제, 덮어쓰기, 권한 변경은 사용자 승인 후에만 한다.

## auto-memory 라우터

auto-memory 의 MEMORY.md 는 경고 머리말만 둔 라우터 파일로 유지하고 주제 항목을 넣지 않는다.
본문은 `<ws>/memory/` 에 두고 auto-memory 에는 `- <topic>: see <ws>/memory/<topic>.md`
형식의 포인터만 둔다(GUIDE §6).
