---
type: Obligation
slug: {{title}}
title: {{title}}
aliases: []
cadence:
  kind:
  anchor:
  graceDays:
dueRule:
owner:
severity:
penalty:
status:
summary:
tags: []
description:
sources: []
confidence:
links:
  requiredBy: []
  ownedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

cadence.kind: oneOff / daily / weekly / monthly / quarterly / semiAnnual / annual / eventDriven
severity: low / medium / high / critical
status: met / partial / unmet / notApplicable

## 무엇을 해야 하는가

## 근거 - requiredBy

비우지 않는다. 근거 없는 의무는 어디서 왔는지 알 수 없다(규칙 14).

## 기한 - dueRule

예: 분기 종료 후 30일 이내. cadence.graceDays 와 함께 다음 기한을 산정한다.

## 소관 - ownedBy

## 이행 상태

status 는 손으로 적는 값이 아니라 증거에서 도출되는 값이다(규칙 15).
유효한 Evidence 가 없는데 met 이면 lint 가 잡는다.

notApplicable 로 둘 때는 이유를 위 summary 나 아래에 반드시 적는다(규칙 18).
이유를 못 대는 비해당은 비해당이 아니라 미검토다.

## 이 의무를 이행하는 통제

여기 손으로 적지 않는다. 정본 방향은 통제 쪽 implements 다.
`grep -rl '\[\[{{title}}\]\]' objects/controls/` 로 뽑는다.

## 이 의무를 충족하는 증거

`grep -rl '\[\[{{title}}\]\]' objects/evidence/` 로 뽑는다.

## 미이행 시 제재 - penalty
