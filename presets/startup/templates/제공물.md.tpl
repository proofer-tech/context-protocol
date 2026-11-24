---
type: 제공물
slug: {{title}}
title: {{title}}
aliases: []
kind:
status: concept
valueProp:
pricing:
launchedAt:
retiredAt:
description:
tags: []
sources: []
links:
  ownedBy: []
  targets: []
  assumes: []
  supersedes: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: product / service / content / platform
status: concept / prototype / beta / live / retired

`status` 기본값이 가장 약한 `concept` 이다. 실제 단계로 올릴 때 근거를 확인한다.

## 이것을 쓰면 무엇이 달라지는가 - valueProp

고객 쪽에서 쓴다. 기능 목록이 아니라 그 사람의 무엇이 달라지는가.

**숫자를 넣으면 출처가 따라온다.** "도입 기간을 2주로 줄인다" 를 적으려면 2주가
측정값인지 목표값인지 갈라야 한다. 측정값이면 근거 가 있어야 하고, 목표값이면
그것은 마일스톤 의 `definitionOfDone` 이다. 규칙 16 이 이 칸을 자주 잡는다.

## 겨냥하는 고객군 - targets

이 제품이 파는 대상 고객군. 정본이 이쪽이다. 고객군 쪽 `servedBy` 는 적지 않는다.

## 딛고 선 전제 - assumes

**이 슬롯이 이 타입에서 가장 값이 크다.** 제품은 항상 몇 개의 믿음 위에 서 있다.
그 믿음을 가설 로 꺼내 여기 걸어 두면, 믿음이 반증됐을 때 무엇이 함께 무너지는지가
한 번의 읽기로 나온다. 걸어 두지 않으면 반증이 가설 폴더 안에서만 일어나고 제품은
그대로 살아남는다. [[startup-lint]] 규칙 17 이 그 상태를 잡는다.

## 가격 - pricing

과금 형태와 값. 미정이면 비운다. 검토 중인 안이 여럿이면 그것은 가설이다.

## 접었을 때

`status: retired` 를 지우지 않는다. **접은 제품이 가장 자주 다시 제안된다.** 왜
접었는지는 대개 반증된 가설에 적혀 있으므로 `assumes` 링크를 남긴 채로 둔다.

## 대체 관계 - supersedes

피봇으로 제품이 갈리면 새 제공물 을 만들고 여기서 옛 것을 가리킨다. 옛 노트를 고쳐
쓰지 않는다. 옛 쪽은 `status` 만 `retired` 로 바꾼다.

역방향은 grep 으로 본다.
`grep -rl '\[\[{{title}}\]\]' objects/제공물/`
