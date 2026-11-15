---
type: Statute
slug: {{title}}
title: {{title}}
aliases: []
kind:
articles: []
authority:
effectiveFrom:
effectiveTo:
amendedAt: []
sourceUrl:
summary:
tags: []
description:
sources: []
confidence:
links:
  supersedes: []
  amendedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: act / decree / rule / notice / ordinance / guideline

## 이 조문이 조직에 요구하는 것

원문을 복사하지 않는다. sourceUrl 로 가리키고 여기에는 조직 관점의 요구사항만 적는다.
원문 전문이 필요하면 datasources/ 에 인덱스를 둔다.

## 적용 조문

| 조문 | 요구 내용 | 우리에게 걸리는 지점 |
|---|---|---|

## 개정 이력 - amendedBy

개정은 덮어쓰지 않는다. 새 인스턴스를 만들고 supersedes 로 잇는다.
이전 판을 지우면 그 판이 유효하던 기간의 증거가 근거를 잃는다.

## 이 법령에서 내려온 규정

여기 손으로 적지 않는다. Regulation 노트가 basedOn 으로 이 노트를 가리키므로
`grep -rl '\[\[{{title}}\]\]' objects/regulations/` 로 뽑는다.

## 메모
