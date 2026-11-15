---
type: Practice
slug: {{title}}
title: {{title}}
aliases: []
kind:
cadence:
owner:
steps:
whyItExists:
lastReviewedAt:
description:
tags: []
sources: []
links:
  ownedBy: []
  authoredBy: []
  appliesTo: []
  guidedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: ritual / procedure / runbook / convention / rotation

## 무엇을 하는가

## 주기 또는 촉발 조건 - cadence

정기적인 것이면 주기를, 절차형이면 무엇이 일어났을 때 도는지를 적는다.

## 순서 - steps

1.
2.
3.

`kind: runbook` 이면 이 섹션이 본체다. 대응 중에 읽는 문서이므로 판단이 아니라
동작을 적는다. 확인할 대시보드 주소와 롤백 명령을 여기 둔다.

## 왜 생겼는가 - whyItExists

**이 섹션이 이 타입의 값이다.** 이유 없는 관행은 아무도 못 바꾼다. 다들 "원래 그랬다"
고만 알고 있어서 손대기를 무서워하고, 그래서 쓸모없어진 뒤에도 계속 돈다.

대개 과거의 Incident 나 Decision 이 원인이다. 링크로 건다.

기억이 안 나면 비운다. 지어내지 않는다. 빈 칸은 "아무도 이유를 모르는 관행" 이라는
정보이고, [[team-ops-lint]] 가 그 목록을 뽑는다.

## 유지 책임 - ownedBy

Team 을 가리킨다.

## 걸리는 대상 - appliesTo

## 근거가 된 결정 - guidedBy

## 마지막 점검 - lastReviewedAt

관행은 유효기간이 있다. 주기적으로 열어보고 여전히 필요한지 판단한 날짜를 적는다.
오래된 순 조회는 [[team-ops-lint]].

**노트를 만들면서 오늘 날짜로 채우지 않는다.** 적어둔 것과 점검한 것은 다르다. 만들
때 채우면 lint 의 "never reviewed" 조회가 첫날부터 무력해지고, 아무도 안 본 관행이
방금 점검된 것으로 집계된다. 실제로 열어보고 판단한 날에 채운다.
