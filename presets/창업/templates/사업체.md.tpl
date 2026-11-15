---
type: 사업체
slug: {{title}}
name: {{title}}
aliases: []
oneLiner:
stage:
problem:
foundedAt:
legalEntity:
team:
industry:
location:
description:
tags: [self, root]
sources: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

stage: idea / prototype / preRevenue / earlyRevenue

이 워크스페이스에 사업체 인스턴스는 하나다. `tags` 의 `self, root` 를 지우지 않는다.
루트 객체라 나가는 링크를 갖지 않으므로 `links:` 블록이 없다.

## 한 문장 - oneLiner

무엇을 하는 사업인가.

**사업계획서 첫 문장을 베끼지 않는다.** 그 문장은 심사용으로 다듬은 것이라 형용사가
많다. 여기는 조회의 앵커라서 짧고 사실적인 편이 낫다.

## 누구의 무슨 문제인가 - problem

우리가 다루는 문제. 우리 제품이 아니라 그 사람이 지금 겪는 것을 쓴다.

## 법인 - legalEntity

법인명과 설립일. **설립 전이면 비운다.** 비어 있는 것이 정상 상태이고, 없다는 사실
자체가 지원사업 자격 판정의 입력이다. "설립 예정" 으로 채우지 않는다. 예정은
마일스톤 이다.

## 팀 - team

현재 구성. 누가 무엇을 맡는가 한 문단.

개별 인물의 이력과 관계가 여기 안 들어갈 만큼 커지면 Person 타입을 만들 시점이다.
절차는 [[창업-객체타입]] 의 워크드 예시에 있다. 미리 만들지 않는다.

## 이 사업체에 달린 것

`offers`, `pursues`, `holds` 슬롯을 두지 않는다. 정본이 각 객체 쪽 `ownedBy` 이고,
여기 또 적으면 규칙 11 위반이다. 역방향은 grep 으로 본다.

`grep -rl '\[\[{{title}}\]\]' objects/제공물/ objects/마일스톤/ objects/가설/`

## 이 프리셋을 벗을 때

졸업 신호 셋은 [[창업]] 에 있다. 여기에는 신호가 걸린 날짜와 판단만 한 줄 남긴다.
이 섹션은 비어 있어도 된다.
