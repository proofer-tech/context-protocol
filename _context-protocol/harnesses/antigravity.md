---
type: document
harness_id: antigravity
title: Harness profile - Google Antigravity
updated: 2026-10-25
---

# 하네스 프로파일: Google Antigravity

Google 의 에이전트 IDE. 호스트 파일시스템에서 돈다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | AGENTS.md (IDE 1.20.5 부터), 루트의 GEMINI.md, `.agents/rules`, 전역 `~/.gemini/GEMINI.md` | 실측(agy CLI 1.4.7, 2026-10-25): 작업 폴더의 AGENTS.md 만 `user_rules` 로 자동 로드됐다. CLAUDE.md 와 상위 폴더 파일은 들어오지 않았다. 서드파티 문서(2026-08-05): AGENTS.md 와 GEMINI.md 가 같이 있을 때의 우선순위는 문서에 없다 |
| `import_syntax` | 미확인 | |
| `host_file_tool` | 내장 파일 도구와 터미널 | |
| `proxy_mount` | no | 추측. 실측 대상 |
| `agent_memory` | 미확인 | |
| `fs_write` | yes | |
| `ask_tool` | 미확인 | 없으면 평문 질문 |
| `deliver_file` | 워크스페이스 경로 보고 | |
| `bootstrap_block` | no. 전역 GEMINI.md 계층은 있다 | |

## 주의

- 실측에서 포털을 따라 CONTEXT.md, MEMORY.md, `agent-harness.md`, `antigravity.md`, `gdrive.md` 순으로
  읽고 하네스 `antigravity`, 백엔드 `gdrive` 로 맞게 판별했다. git 은 `gdrive.md` 규칙으로 금지라고 답했다.
- CLI(`agy`)의 헤드리스 모드(`-p`)는 셸 권한을 물을 수 없어 자동 거부한다. 읽기 실측도
  `--dangerously-skip-permissions` 나 settings.json 허용 규칙이 있어야 돈다. 실측은 plan 모드와 수정 금지
  지시로 돌렸고 루트 파일 목록이 실행 전후로 같았다.

- GEMINI.md 포털은 두지 않는다. AGENTS.md 를 읽지 못하는 구버전이면 IDE 를 올리라고 안내한다.
