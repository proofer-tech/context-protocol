---
type: Regulation
slug: {{title}}
title: {{title}}
aliases: []
kind:
version:
effectiveFrom:
effectiveTo:
reviewCycle:
  kind:
  anchor:
  graceDays:
approvedBy:
owner:
location:
summary:
tags: []
description:
sources: []
confidence:
links:
  basedOn: []
  ownedBy: []
  supersedes: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: policy / standard / procedure / manual / guideline

## 무엇을 규율하는가

## 정본 위치 - location

이 값을 비우지 않는다. 없으면 이 노트가 요약본으로 전락한다.
URL, 시스템 경로, 오프라인 보관 장소 중 하나. 접근 권한이 필요하면 그 사실도 적는다.

## 외부 근거 - basedOn

## 소관 - owner, ownedBy

`owner` 는 필수다. 유지 책임을 지는 조직 단위를 가리킨다. 제정 승인 주체
(`approvedBy`)와 다를 수 있다. 위원회가 승인하고 실무 부서가 유지하는 형태가 흔하다.

책임은 조직 단위에 붙는다. 사람 이름은 Unit 노트의 currentHolder 에만 산다(규칙 13).

## 이전 판 - supersedes

## 이 규정에서 도출된 의무

여기 손으로 적지 않는다. 정본 방향은 의무 쪽 requiredBy 다.
`grep -rl '\[\[{{title}}\]\]' objects/obligations/` 로 뽑는다.

## 재검토 이력

| 시점 | 결과 | 판 번호 |
|---|---|---|
