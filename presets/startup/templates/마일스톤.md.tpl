---
type: 마일스톤
slug: {{title}}
title: {{title}}
aliases: []
status: planned
definitionOfDone:
startDate:
dueDate:
doneAt:
outcome:
description:
tags: []
sources: []
links:
  ownedBy: []
  tests: []
  delivers: []
  fundedBy: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

status: planned / active / done / missed / dropped

**마일스톤은 틀리지 않는다.** 하거나 못 할 뿐이다. 틀릴 수 있는 문장은 가설 다.
"3월까지 파일럿 다섯 곳" 은 여기이고 "이 고객군은 도입 기간에 민감하다" 는 저쪽이다.
둘을 가르는 기준은 [[startup]] 에 있다.

## 무엇이 되면 끝난 것인가 - definitionOfDone

관측 가능하게 쓴다. "파일럿을 붙인다" 가 아니라 "유상 계약 다섯 건에 서명한다" 다.
여기가 모호하면 나중에 done 인지 missed 인지 본인도 판정하지 못한다.

## 무엇을 시험하는가 - tests

**이 슬롯이 이 타입의 값이다.** "파일럿 다섯 곳" 은 그 자체로는 일정이고, 어느 가설을
시험하려는지가 붙어야 결과를 읽을 수 있다. 다섯 곳을 붙였는데 아무도 재계약하지 않으면
`status: done` 이면서 그 가설은 `invalidated` 다. 이 조합이 표현되는 것이 설계 목적이다.

정본이 이쪽이다. 가설 쪽 `testedBy` 는 적지 않는다.

## 무엇을 내놓는가 - delivers

이 일이 만들어 내는 제공물 또는 제출문서.

## 재원 - fundedBy

이 일을 받치는 자금. 정본이 이쪽이다. 지원사업 하나가 여러 마일스톤을 덮고
마일스톤은 계속 늘어나므로 소비하는 쪽에 적는다. 자금 쪽 `funds` 는 적지 않는다.

## 실제로 무엇이 달라졌나 - outcome

**`outcome` 없이 닫지 않는다.** 특히 `dropped` 가 그렇다. 왜 안 하기로 했는지가
없으면 같은 일감이 반년 뒤에 다시 올라온다.

`missed` 와 `dropped` 를 구분한다. 전자는 하려다 못 한 것이고 후자는 안 하기로 한
것이다. 반년 뒤에 읽는 사람에게 뜻이 완전히 다르다.

## 결과가 가설에 준 것

이 마일스톤이 끝났으면 `tests` 로 걸린 가설을 열어 상태를 갱신한다. 관측이 나왔으면
근거 노트를 만들고 그쪽에서 `supports` 또는 `refutes` 를 건다. 여기 문장으로
적어 두면 그 관측에 `sampleSize` 가 붙지 않는다.
