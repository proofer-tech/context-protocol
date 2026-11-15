---
type: document
harness_id: chat-upload
title: Harness profile - file-upload chat
updated: 2026-10-25
---

# 하네스 프로파일: 파일 업로드형 대화

ChatGPT 프로젝트, Gemini 의 Gem 처럼 폴더를 연결하지 못하고 파일을 첨부하거나 지침을
붙여넣는 대화형 제품. 에이전트가 워크스페이스에 쓸 수 없다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `entry_file` | none | 자동으로 읽는 파일이 없다 |
| `import_syntax` | none | |
| `host_file_tool` | none | 첨부된 파일만 읽는다 |
| `proxy_mount` | 해당 없음 | |
| `agent_memory` | 제품의 계정 메모리 | |
| `fs_write` | no | |
| `ask_tool` | none | |
| `deliver_file` | 다운로드 파일, 또는 대화 본문 | |
| `bootstrap_block` | yes. 프로젝트 지침이나 커스텀 지침 | |

## 상태

미검증. 2026-10-25 임한솔 결정으로 실측을 보류했다. ChatGPT 는 Work 모드에서 폴더를 지정하면 Codex 로
돌아 정식 경로로 쓸 수 있으므로([[codex]]) 그쪽으로 안내하고, 이 프로파일은 폴더를 열 수 없는 환경을 위한
규칙으로만 남긴다. 설치 패키지 README 는 이 모드를 "미검증" 으로 표시한다.

## 열람 모드

프로토콜의 중심인 능동 축적(GUIDE §12)이 동작하지 않으므로 정식 지원으로 두지 않는다.

1. 사용자가 CONTEXT.md, `memory/MEMORY.md`, 필요한 본문을 첨부한다. 첨부되지 않은 파일은
   없는 것이 아니라 못 본 것이다. "없다" 고 답하지 않고 어느 파일이 필요한지 말한다.
2. 조회는 GUIDE §3 순서를 따르되 L1 은 첨부된 파일뿐이다.
3. 기록할 사실이 생기면 넣을 경로, 종류(지식, 메모리, action-log), 본문을 사용자에게 건넨다.
   사람이 워크스페이스에 반영한다. 제품 계정 메모리에 본문을 두지 않는다.

## 붙여넣기 지침

제품의 프로젝트 지침(커스텀 지침)에 아래 글을 붙여넣고, CONTEXT.md, `memory/MEMORY.md`, 이 파일을
첨부한다. 설치 패키지에도 같은 글을 싣는다. 이 글은 포털과 같은 규약을 따른다. 규칙을 늘리지 않고
정본과 이 프로파일로 보낸다.

```
This project works with a context-protocol workspace. The user attaches its files here; you cannot read or write the workspace folder itself.

1. The rule canon is the attached CONTEXT.md. Read it before anything else and follow it together with the attached harness profile chat-upload.md. Where CONTEXT.md assumes you can read or write workspace files directly, chat-upload.md decides instead.
2. Your harness is chat-upload: no auto-loaded entry file, no host file tool, no workspace write.
3. Lookup: answer only from attached files. A file that is not attached is unseen, not absent. Never say something does not exist in the workspace; name the file you would need instead.
4. Recording: when something should be recorded, do not say it was saved and do not keep it in this product's memory. Give the user the target path, the kind (knowledge, memory, or action-log), and the exact text to add, so a person can put it into the workspace.
5. Reply in the user's language.
```
