---
type: 자금
slug: {{title}}
title: {{title}}
aliases: []
kind:
status: watching
provider:
amount:
announcedAt:
deadline:
decidedAt:
eligibility:
useOfFunds:
description:
tags: []
sources: []
links:
  ownedBy: []
  requires: []
  assumes: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: grant / program / investment / loan / prize / revenue
status: watching / preparing / applied / selected / rejected / contracted / closed

`status` 기본값이 가장 약한 `watching` 이다. 공고를 보고만 있는 상태가 대부분이고,
준비를 시작한 날에 `preparing` 으로 올린다.

`selected` 와 `contracted` 를 나눈다. 그 사이에 협약이라는 절차가 있고 거기서 조건이
바뀐다. 선정 금액과 협약 금액이 다른 경우가 흔하다.

## 자격요건 - eligibility

**요약하지 말고 판정에 쓰이는 조건만 옮긴다.** 창업 3년 이내, 대표 연령, 소재지,
중복 수혜 제한, 업종 제한. 이 다섯이 실제로 떨어뜨리는 조건이고 나머지는 읽을 필요가
없다.

**공고 본문을 복사하지 않는다.** 공고는 개정되고 복사본은 그 사실을 모른다. 원문
링크는 `sources` 에 둔다.

## 금액 - amount

금액과 단위. 지원금이면 자부담 비율까지. 이 값의 출처는 공고이므로 `sources` 에 공고
링크가 있으면 규칙 16 을 통과한다.

## 요구 제출물 - requires

이 공고가 요구하는 서류를 제출문서 로 건다. **제출물 체크리스트 자리다.** 아직
제출문서 가 없는 것이 곧 할 일이고, 그 조회가 마감 직전에 값이 가장 크다.

`[[창업-린트]]` 레시피 (b) 가 그것을 낸다.

## 딛고 선 전제 - assumes

이 공고에 내기로 한 판단이 기대고 있는 가설. 사업 방향에 대한 전제가 반증되면
이 지원사업 자체가 안 맞게 되는 경우가 있고, 규칙 17 이 그 상태를 잡는다.

## 쓸 곳 - useOfFunds

집행 제한이 있으면 함께 적는다. 인건비 비중 제한과 장비 구입 제한이 대표적이고,
그것이 마일스톤 계획을 바꾼다.

## 이 자금이 받치는 일

`funds` 슬롯을 두지 않는다. 정본이 마일스톤 쪽 `fundedBy` 다.

`grep -rl '\[\[{{title}}\]\]' objects/마일스톤/`

## 떨어졌을 때

`status: rejected` 를 지우지 않는다. **탈락한 공고가 이듬해 같은 조건으로 다시
나온다.** 그때 필요한 것이 작년에 무엇을 냈고 왜 떨어졌는지다. 피드백을 받았으면
본문 아래에 그대로 옮겨 적는다.
