---
type: Metric
slug: {{title}}
name: {{title}}
aliases: []
kind:
definition:
owner:
target:
source:
cadence:
description:
tags: []
sources: []
links:
  ownedBy: []
  observes: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: health / delivery / quality / business

## 정확히 무엇을 세는가 - definition

계산식을 적는다. 분자와 분모, 집계 구간, 제외 조건까지.

**현재 값을 적지 않는다.** 값은 대시보드에 있고 여기 적는 순간 스테일해진다. 이
노트가 답해야 하는 것은 "그 숫자가 정확히 무엇을 세는가" 다. 같은 이름의 지표를
두 사람이 다르게 계산하는 것이 팀에서 가장 흔한 숫자 사고다.

## 어디서 나오는가 - source

## 목표값 - target

목표가 없으면 비운다. 없는 목표를 지어내면 그 숫자가 평가처럼 읽힌다.

## 보는 주기 - cadence

## 책임 팀 - ownedBy

## 보는 대상 - observes

## 이 지표를 움직이려는 일

여기 적지 않는다. 정본은 Initiative 쪽 `movesMetric` 이다. 이니셔티브는 끝나면 닫히고
그 시점에 목록이 고정되므로, 지표 노트에 쌓으면 노트가 무한히 길어진다.
`grep -rl '\[\[{{title}}\]\]' objects/initiatives/`

## 해석 주의

이 숫자가 좋아 보이는데 상황이 나쁠 수 있는 경우, 또는 그 반대. 아는 것이 있으면
여기 적는다. 지표를 처음 보는 사람이 오독하는 지점이 대개 여기다.
