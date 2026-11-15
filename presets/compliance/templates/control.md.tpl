---
type: Control
slug: {{title}}
title: {{title}}
aliases: []
kind:
automation:
cadence:
  kind:
  anchor:
  graceDays:
owner:
system:
procedure:
lastRunAt:
tags: []
description:
sources: []
confidence:
links:
  implements: []
  ownedBy: []
  dependsOn: []
produces:
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: preventive / detective / corrective
automation: manual / semiAuto / automated
cadence.kind: oneOff / daily / weekly / monthly / quarterly / semiAnnual / annual / eventDriven

## 무엇을 어떻게 하는가

## 실행 절차 - procedure

1.
2.
3.

## 어떤 의무를 이행하는가 - implements

이 술어가 정본이다. 통제 하나가 여러 의무를 동시에 충족하는 경우가 흔해서
통제 쪽에 모아 둔다. 의무 노트에 implementedBy 를 함께 적지 않는다(규칙 11).

## 운영 주체 - ownedBy

## 사용 시스템 - system

## 남기는 증거의 종류 - produces

**인스턴스 목록이 아니다.** 어떤 종류의 증거가 나오는지를 한 번 적어두는 자리다.
증거는 실행할 때마다 쌓이므로 여기에 목록을 두면 이 노트가 무한히 길어지고 매 실행
마다 두 곳을 고치게 된다. 정본은 증거 쪽 `producedBy` 와 `evidenceFor` 다.

그래서 이 키는 `links:` 맵 밖에 있다. 값은 위키링크가 아니라 "분기별 IAM 검토 승인
이력" 같은 서술이다.

실제로 쌓인 증거 목록은 조회한다.
`grep -rl '\[\[{{title}}\]\]' objects/evidence/`

automation 이 manual 이면 증거가 잘 끊긴다. 무엇이 어디에 남는지 여기 적어 둔다.

## 선행 통제 - dependsOn

## 실행 이력

| 시점 | 결과 | 증거 |
|---|---|---|
