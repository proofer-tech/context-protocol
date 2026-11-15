---
type: Team
slug: {{title}}
name: {{title}}
aliases: []
mission:
formedAt:
disbandedAt:
parentTeam:
chargeOf:
notChargeOf:
description:
tags: []
sources: []
links:
  partOf: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

## 이 팀이 존재하는 이유 - mission

## 책임 범위 - chargeOf

## 책임 밖 - notChargeOf

우리 일이 아닌데 우리한테 오는 것. 인접 팀과 매번 다투는 지점을 여기 적으면 그 다툼이
한 번으로 끝난다. 이 섹션이 이 노트에서 값이 가장 크다.

## 상위 조직 - partOf

## 구성원

여기 명단을 박지 않는다. 각 Person 노트가 `memberOf` 로 이 팀을 가리키므로
`grep -rl '\[\[{{title}}\]\]' objects/people/` 로 뽑는다. 명단을 양쪽에 두면 사람이
나갈 때 두 곳을 고쳐야 하고 대개 한 곳만 고친다.

## 이 팀이 소유하고 돌리는 것

여기 목록을 박지 않는다. 소유의 정본은 각 객체의 `ownedBy` 쪽이다.
`grep -rl '\[\[{{title}}\]\]' objects/systems/ objects/metrics/ objects/practices/ objects/initiatives/`

`owns` / `runs` / `pursues` 는 어휘에는 있으나 비정본이다. 여기 적으면 객체가 늘 때마다
이 노트를 함께 고쳐야 하고, 대개 한쪽만 고쳐서 두 목록이 어긋난다.

## 메모

루트 팀이면 `tags: [self, root]` 를 단다.
