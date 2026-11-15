---
type: Person
name: {{title}}
aliases: []
role:
kind:
joinedAt:
leftAt:
contact:
focus: []
description:
tags: []
sources: []
links:
  memberOf: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: member / lead / external / alumni

## 역할

## 소속 - memberOf

## 지금 보는 영역 - focus

**담당이 아니라 현재 관심이다.** 소유는 사람이 아니라 팀에 붙는다. 여기 적힌 것으로
"이건 이 사람 영역" 을 정당화하지 않는다.

## 식별자

슬랙 핸들, 깃허브 아이디 등. 두 개 이하면 이 섹션을 지우고 aliases 로 끝낸다.

| value | kind | context | status |
|---|---|---|---|

## 참여 이력

여기 손으로 적지 않는다. Initiative 가 `hasParticipant`, Decision 이 `decidedBy`,
System 이 `oncall` 로 이 노트를 가리킨다.
`grep -rl '\[\[{{title}}\]\]' objects/` 로 뽑는다.

## 이탈 시

노트를 지우지 않는다. `leftAt` 을 적고 `kind: alumni` 로 바꾼다. 그리고 이 사람에게
걸린 `oncall` 을 찾아 옮긴다. 두 번째를 빼먹는 것이 가장 흔한 사고다
([[team-ops-lint]] 의 이탈자 잔재 검사).
