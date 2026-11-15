---
type: Unit
name: {{title}}
aliases: []
kind:
currentHolder:
holderSince:
contact:
mandate:
tags: []
description:
sources: []
confidence:
links:
  partOf: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: department / team / committee / role / external

## 책임 범위 - mandate

## 상위 단위 - partOf

상위 단위는 프로퍼티가 아니라 이 링크 하나로만 적는다. 프로퍼티와 링크에 같은 사실을
두 번 적으면 갱신이 갈라진다.

## 현재 담당자

사람 이름은 이 노트의 currentHolder 에만 산다. 사슬의 링크는 절대 사람을 가리키지
않는다(규칙 13). 담당자가 바뀌면 currentHolder 와 holderSince 만 고치고 로그에 남긴다.

| 담당자 | 직책 | 시작 | 종료 |
|---|---|---|---|

이전 담당자를 지우지 말고 여기 이력으로 남긴다.

## 연락 경로 - contact

## 이 단위가 지는 책임

여기 손으로 적지 않는다. 정본 방향은 각 객체 쪽 ownedBy 다.
`grep -rl '\[\[{{title}}\]\]' objects/` 로 뽑는다.

accountableFor 를 이 노트에 적는 것은 단위가 아주 커져서 훑기가 필요할 때만이고,
그때도 ownedBy 와 양쪽에 적지 않는다(규칙 11).

## 외부 단위

kind: external 은 외부 위탁처와 감사인이다. 조직 단위는 아니지만 책임을 지므로
같은 타입에 둔다.
