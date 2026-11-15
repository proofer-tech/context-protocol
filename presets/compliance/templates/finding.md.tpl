---
type: Finding
slug: {{title}}
title: {{title}}
aliases: []
severity:
raisedAt: {{date:YYYY-MM-DD}}
dueAt:
closedAt:
owner:
remediation:
rootCause:
tags: []
description:
sources: []
confidence:
links:
  raisedBy: []
  affects: []
  ownedBy: []
  resolvedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

severity: observation / minor / major / critical

## 무엇이 문제인가

## 출처 - raisedBy

이 술어가 정본이다. 지적사항은 감사가 끝난 뒤에도 혼자 굴러가므로
자기 출처를 스스로 들고 있어야 근거를 잃지 않는다.

## 무엇이 결함인가 - affects

사슬의 어느 마디가 끊겼는지 가리킨다. 의무가 없어서 난 지적, 통제가 안 돌아서 난 지적,
증거가 없어서 난 지적은 시정 방법이 전부 다르다.

## 시정 책임 - ownedBy

owner 와 dueAt 없이 만들지 않는다. 추적되지 않는 지적은 다음 점검에서 그대로 다시 나온다.

## 근본 원인 - rootCause

## 시정 계획과 진행 - remediation

| 시점 | 조치 | 상태 |
|---|---|---|

## 종결 - closedAt, resolvedBy

증거 없이 닫지 않는다. 증거 없는 종결은 지적사항을 없앤 것이 아니라 숨긴 것이다.
기한만 미루는 것은 종결이 아니다. dueAt 을 갱신하고 로그에 남긴다.

closedAt 이 비고 dueAt 이 지났으면 lint 규칙 17 이 잡는다.
