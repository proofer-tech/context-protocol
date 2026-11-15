---
type: Incident
slug: {{title}}
title: {{title}}
aliases: []
severity:
startedAt:
detectedAt:
resolvedAt:
owner:
impact:
rootCause:
timeline:
description:
tags: []
sources: []
links:
  affects: []
  ownedBy: []
  involvedPerson: []
  triggers: []
  similarTo: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

severity: sev1 / sev2 / sev3 / nearMiss

등급 기준은 팀마다 다르다. 이 워크스페이스의 기준은 Practice 인스턴스에 있다.

## 시각

| | 시각 |
|---|---|
| 시작 - startedAt | |
| 인지 - detectedAt | |
| 복구 - resolvedAt | |

`detectedAt` 을 `startedAt` 과 같은 값으로 채우지 않는다. 모르면 비운다. 같은 값을
넣으면 관측 지연이 0 으로 집계되고, 두 값을 따로 두는 이유가 사라진다.

## 영향 - impact

누가 무엇을 못 했는가. 시스템이 아니라 사용자 쪽에서 쓴다.

## 영향받은 시스템 - affects

## 경과 - timeline

시각별로 무슨 일이 있었고 무엇을 했는지.

- HH:MM
- HH:MM

## 근본 원인 - rootCause

**사람 이름을 적지 않는다.** 사람이 실수할 수 있는 상태로 시스템을 둔 것이 근본
원인이다. 이 워크스페이스는 그 사람도 읽는다.

## 대응 참여 - involvedPerson

"대응에 참여한 사람" 이지 "실수한 사람" 이 아니다.

## 회고에서 나온 것 - triggers

**여기 문장으로 적지 말고 객체로 꺼낸다.** 절차가 바뀌면 Practice, 방침이 바뀌면
Decision, 일감이 생기면 Initiative 다. 꺼내서 링크로 건다.

문서 안에만 적힌 액션 아이템은 실행되지 않는다. 복구된 sev1 에 이 링크가 하나도
없으면 [[team-ops-lint]] 가 경고로 잡는다.

정말로 바꿀 것이 없었으면 그 판단을 한 줄 적는다. 다음 사람이 같은 검사를 또 돌리지
않게 한다.

## 같은 계열 - similarTo

세 번째 같은 사건이 나면 계열 자체를 Decision 이나 Practice 로 승격할 신호다.

## 첨부

로그 발췌, 그래프 캡처가 쌓이면 동명 서브폴더를 만들고 이 노트를 그 안으로 옮긴다.
대응 중에는 여러 사람이 동시에 쓰므로 미리 만드는 편이 낫다([[team-ops-layout]]).
