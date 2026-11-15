---
type: concept
scheme: context-protocol
pref_label_ko: 객체 템플릿
pref_label_en: Object template
broader: "[[personal-rag]]"
related:
definition: personal-rag 객체 타입별 인스턴스 생성 템플릿. frontmatter 필수 키와 본문 섹션 골격을 담아 새 객체가 필수 프로퍼티와 관계 슬롯을 빠뜨리지 않게 한다.
updated: 2026-08-18
---

# 객체 템플릿 (폴더 개념)

이 노트는 `presets/personal-rag/templates/` 폴더의 개념 노트다. 이 폴더 안의
`.md.tpl` 파일들이 타입별 템플릿이다.

## 왜 `.md.tpl` 인가

템플릿의 frontmatter 는 `type: Person` 같은 객체 타입 값을 갖는다. 이를 `.md` 로 두면
lint 가 프로퍼티가 텅 빈 실제 인스턴스로 오인하고 규칙 8(필수 프로퍼티) 위반으로
잡는다. 비-md 파일은 메타 검사 대상이 아니므로(GUIDE §10 유추 기준) `.md.tpl` 로 둔다.

부수 효과로 "이건 채워 넣을 껍데기"라는 신호가 파일명에 남는다.

## 수록 템플릿

- `person.md.tpl`
- `organization.md.tpl`
- `project.md.tpl`
- `event.md.tpl`
- `place.md.tpl`
- `idea.md.tpl`
- `artifact.md.tpl`

## 사용법

에이전트: 이 폴더의 해당 `.md.tpl` 을 읽고, 플레이스홀더를 채워
`objects/<type>/<PK>.md` 로 쓴다. `{{title}}` 은 파일명(PK), `{{date}}` 은 오늘 날짜
(절대값)로 치환한다. 값이 없는 키는 지우지 말고 비워 둔다. 나중에 채울 슬롯이
남아 있는 것이 그 자체로 정보다. 단 필수 프로퍼티(각 타입의 O 표시)는 비우지 않는다.

Obsidian 을 쓰는 워크스페이스: `_context-protocol/templates/` 로 복사하고 `.tpl` 을 떼면 Templater
가 `{{title}}` / `{{date:YYYY-MM-DD}}` 를 처리한다.

관계 섹션의 빈 `[[ ]]` 는 채우거나 섹션째로 지운다. 빈 위키링크를 남기면 lint 규칙 9
(링크 해소)에서 dangling 으로 잡힌다.
