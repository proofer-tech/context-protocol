---
type: document
harness_id: codex
title: Harness profile - Codex
updated: 2026-10-25
---

# 하네스 프로파일: Codex

OpenAI Codex CLI 와 앱, 그리고 ChatGPT 앱에서 폴더를 지정한 Work 모드. 호스트 파일시스템에서 돌고, 쓰기 범위를 작업 폴더로 묶는
자체 샌드박스 모드가 있다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | AGENTS.override.md, AGENTS.md, 설정의 fallback 파일명 | 실측(codex-cli 0.160.0, 2026-10-25): git 루트가 없는 드라이브 폴더에서도 작업 폴더의 AGENTS.md 가 프로젝트 지침으로 들어왔다. 문서: 프로젝트 루트(보통 git 루트)부터 작업 폴더까지 폴더마다 하나씩 이어 붙이고, 가까운 쪽이 뒤에 와서 우선한다. 합계 32 KiB 상한(`project_doc_max_bytes`) |
| `import_syntax` | none | 문서에 없음 |
| `host_file_tool` | 자체 셸 명령과 패치 도구 | 실측 대상 |
| `proxy_mount` | no | 추측. 작업 폴더 안의 삭제가 되는지 실측 대상 |
| `agent_memory` | 미확인 | 실측 대상 |
| `fs_write` | yes. 읽기 전용 모드로 띄우면 no | |
| `ask_tool` | none | 번호를 붙인 평문 질문 |
| `deliver_file` | 워크스페이스 경로 보고 | |
| `bootstrap_block` | no | |

## 주의

- 드라이브 워크스페이스는 git 저장소가 아니다. git 루트가 없으면 작업 폴더의 AGENTS.md 를
  읽으므로(실측) 워크스페이스 루트에서 띄운다. `codex exec` 는 git 저장소 밖에서
  `--skip-git-repo-check` 가 있어야 돈다.
- ChatGPT 앱의 Work 모드에서 폴더를 지정하면 Codex desktop 런타임으로 돈다(실측 2026-10-25, 임한솔 실행).
  AGENTS.md 가 프로젝트 지침으로 들어왔고 CLI 실측과 같은 순서로 정본에 들어가 하네스 `codex`, 백엔드
  `gdrive`, git 금지를 맞게 답했다. 그래서 ChatGPT 사용자는 파일 업로드형이 아니라 이 경로로 안내한다.
- AGENTS.md 포털은 정본을 끌어오지 못한다. 실측에서 포털 지시대로 CONTEXT.md, MEMORY.md,
  `codex.md`, 백엔드 프로파일 순으로 읽고 하네스를 `codex` 로 맞게 판별했다.
- 읽기 전용 모드(`-s read-only`)에서는 `fs_write: no` 로 스스로 판정했다. `proxy_mount` 는 쓰기
  모드 실측이 남았다.
