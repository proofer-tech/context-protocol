---
type: concept
scheme: context-protocol
pref_label_ko: 객체 템플릿
pref_label_en: Object template
broader: "[[team-ops]]"
related:
definition: team-ops 객체 타입별 인스턴스 생성 템플릿. frontmatter 필수 키와 본문 섹션 골격을 담아 새 객체가 필수 프로퍼티와 관계 슬롯을 빠뜨리지 않게 한다.
updated: 2026-09-10
---

# 객체 템플릿 (폴더 개념)

이 노트는 `presets/team-ops/templates/` 폴더의 개념 노트다. 이 폴더 안의 `.md.tpl`
파일들이 타입별 템플릿이다.

## 왜 `.md.tpl` 인가

템플릿의 frontmatter 는 `type: Decision` 같은 객체 타입 값을 갖는다. 이를 `.md` 로
두면 lint 가 프로퍼티가 텅 빈 실제 인스턴스로 오인하고 규칙 8(필수 프로퍼티) 위반으로
잡는다. 비-md 파일은 메타 검사 대상이 아니므로(GUIDE §10 유추 기준) `.md.tpl` 로 둔다.

부수 효과로 "이건 채워 넣을 껍데기" 라는 신호가 파일명에 남는다.

## 수록 템플릿

- `team.md.tpl`
- `person.md.tpl`
- `initiative.md.tpl`
- `decision.md.tpl`
- `practice.md.tpl`
- `system.md.tpl`
- `incident.md.tpl`
- `metric.md.tpl`

## 사용법

에이전트: 이 폴더의 해당 `.md.tpl` 을 읽고, 플레이스홀더를 채워
`objects/<type>/<PK>.md` 로 쓴다. `{{title}}` 은 파일명(PK), `{{date}}` 은 오늘 날짜
(절대값)로 치환한다. 값이 없는 키는 지우지 말고 비워 둔다. 나중에 채울 슬롯이 남아
있는 것이 그 자체로 정보다. 단 필수 프로퍼티(각 타입의 O 표시)는 비우지 않는다.

Obsidian 을 쓰는 워크스페이스: `_context-protocol/templates/` 로 복사하고 `.tpl` 을 떼면 Templater
가 `{{title}}` / `{{date:YYYY-MM-DD}}` 를 처리한다.

관계 섹션의 빈 `[[ ]]` 는 채우거나 섹션째로 지운다. 빈 위키링크를 남기면 lint 규칙 9
(링크 해소)에서 dangling 으로 잡힌다.

## 팀 워크스페이스에서의 배치 권장

[[team-ops-apply]] Step 4 는 대상 워크스페이스로 **복사하는 쪽**을 권장한다. 여러
사람이 각자 노트를 만들 때 프리셋 폴더까지 찾아 들어가지 않고, 안 찾으면 손으로 대충
만든다. 손으로 만든 Decision 노트는 대개 `consequences` 가 없고, 손으로 만든 부속
노트는 대개 `subject` 가 없다.

## 아홉 파일이 공유하는 규약

타입별 템플릿 여덟 개는 슬롯 구성이 서로 다르지만 아래 셋은 같다. 이 노트가 그 셋의
정본이고, 새 타입을 추가할 때도 같이 맞춘다.

**1. 공통 슬롯은 여덟 개 모두에 둔다.** `aliases`, `tags`, `description`, `sources`,
`updated`. [[team-ops-schema]] 의 공유 프로퍼티가 `sources` 와 `updated` 를 전체로
선언하고 HasIdentity 가 `aliases` 를 8종 전부에 요구한다. 한 타입에만 있으면 그
타입에서만 출처를 남기게 되고, 출처 없는 사실이 이 워크스페이스에서 가장 자주 다투는
대상이다.

**2. 비정본 슬롯을 두지 않는다.** 역방향 술어는 어휘에 있어도 빈 슬롯으로 제공하지
않는다. 빈 슬롯은 채우라는 지시로 읽히고, 채우면 상대 노트와 같은 사실이 두 곳에
적혀 규칙 11 위반이 된다. 정본 방향 요약표는 [[team-ops-schema]] 규칙 11 아래에 있다.
빠진 슬롯 자리에는 grep 레시피 한 줄을 본문에 둔다.

**3. 날짜를 미리 채우지 않는다.** `updated` 만 예외다. 그것은 노트를 만지는 날이므로
오늘이 맞다. `formedAt`, `startDate`, `lastReviewedAt`, `startedAt` 은 전부 비운다.
팀 결성일이 노트 생성일일 리 없고, `lastReviewedAt` 프리필은 [[team-ops-lint]] 의
"never reviewed" 조회를 첫날부터 무력화한다. [[team-ops-intake]] 의 "추측한 값을
미리 채우지 않는다" 와 같은 원칙이고, 여기서 어기면 그 원칙이 파일 안에서 먼저
깨진 채로 배포된다.

## 템플릿에 본문 섹션을 둔 이유

frontmatter 만 있으면 값은 채워지는데 서술이 안 채워진다. 이 프리셋에서 값이 큰 것은
`context`, `rationale`, `consequences`, `whyItExists`, `notChargeOf` 처럼 전부 서술
필드다. 섹션 제목이 비어 있는 채로 남아 있는 것이 "여기 뭔가 들어가야 한다" 는 가장
싼 신호다.

각 섹션 아래의 안내 문장은 채우면서 지운다. 남겨두면 인스턴스가 설계 문서를 흉내내는
꼴이 된다.

## 새 타입을 만들면

[[team-ops-object-types]] 의 "8종에 없는 것이 나오면 타입을 만든다" 를 따라 타입을
추가했으면 `templates/<타입>.md.tpl` 을 함께 만들고 위 수록 목록에 한 줄 더한다.
