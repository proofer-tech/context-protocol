---
type: 근거
slug: {{title}}
title: {{title}}
aliases: []
kind:
collectedAt:
sampleSize:
finding:
method:
source:
description:
tags: []
sources: []
links:
  supports: []
  refutes: []
  ownedBy: []
  aboutSegment: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: interview / survey / experiment / usage / sale / desk / expert

**이 템플릿은 짧게 쓰라고 있다.** 날짜, 대상, 규모, 들은 것 네 줄이면 성립한다.
길이가 아니라 존재가 값이다. 아래 섹션을 다 채우려다 노트를 안 만들게 되는 것이 이
타입에서 가장 흔한 실패이고, 그렇게 되면 `sampleSize` 가 사라진다. 반년 뒤 그 문장을
읽는 사람은 3건인지 30건인지 모르고 대개 큰 쪽으로 읽는다.

예를 들어 이만큼이면 이미 성립한다.

```
collectedAt: 2026-08-14
sampleSize: n=5
kind: interview
finding: 다섯 곳 중 네 곳이 가격을 먼저 묻지 않고 도입 기간을 먼저 물었다
```

## 무엇이 관측됐는가 - finding

**해석을 섞지 않는다.** "가격에 민감하지 않았다" 는 해석이고 "다섯 곳 중 네 곳이
가격을 먼저 묻지 않았다" 가 관측이다. 해석은 가설 쪽에 있고, 둘을 같은 칸에 적으면
이 프리셋이 하려는 분리가 그 자리에서 무너진다.

## 규모 - sampleSize

세는 단위까지 적는다. `n=3`, `매출 2건`, `공고 82건`. `kind: expert` 는 진술이라
`sampleSize` 가 1 이고, 1 이라고 적는 것이 이 타입의 규율이다.

## 어떻게 모았는가 - method

질문지, 표집 방식, 실험 조건. 비워도 된다.

## 지지와 반증 - supports / refutes

정본이 이쪽이다. 가설 쪽 `supportedBy` 와 `refutedBy` 는 적지 않는다.

**한 관측이 여러 가설을 건드리는 것은 정상이다.** 인터뷰 한 건이 가격 가설을
지지하면서 채널 가설을 반증할 수 있다. 둘을 동시에 갖는 노트가 나오면 잘 쓴 노트다.

## 출처 - source

`kind: desk` 는 남이 만든 자료다. 통계청, 연구보고서, 기사. **이 칸을 비우면 안 된다.**

## 원본 첨부

녹취와 설문 원본이 쌓이면 동명 서브폴더를 만들고 이 노트를 그 안으로 옮긴다
([[창업-레이아웃]]).
