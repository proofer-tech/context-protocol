---
type: Audit
slug: {{title}}
title: {{title}}
aliases: []
kind:
auditor:
startDate: {{date:YYYY-MM-DD}}
endDate:
scope:
result:
tags: []
description:
sources: []
confidence:
links:
  scopeCovers: []
  performedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: internal / external / certification / regulatory / selfCheck
result: pass / passWithFindings / fail / inProgress

## 점검 개요

## 범위 - scopeCovers

범위를 산문으로만 적으면 다음 점검 때 다시 짜야 한다.
객체를 직접 가리키면 범위가 재사용된다.

## 수행 주체 - performedBy

`auditor` 와 `performedBy` 는 쓰임이 갈린다. `auditor` 는 **외부 수행 주체의 이름**을
적는 전용 칸이라 평문이 정상이고, 사내 주체는 그 칸을 비우고 `performedBy` 로 Unit 을
건다. 외부 감사인을 Unit 으로도 두고 싶으면 `kind: external` 인 Unit 을 만들어
`performedBy` 로 걸고 `auditor` 는 비운다. 둘 다 채우지 않는다.

## 결과

endDate 가 비어 있으면 진행 중이다.

## 이 점검에서 나온 지적사항

여기 손으로 적지 않는다. 정본 방향은 지적 쪽 raisedBy 다.
`grep -rl '\[\[{{title}}\]\]' objects/findings/` 로 뽑는다.

## 회차

점검은 회차마다 새 인스턴스다. 같은 점검을 매년 돌아도 한 노트를 덮어쓰지 않는다.
덮어쓰면 작년 지적사항의 출처가 사라진다.

## 메모
