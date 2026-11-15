---
type: 제출문서
slug: {{title}}
title: {{title}}
aliases: []
kind:
version:
status: draft
authoredAt:
submittedTo:
submittedAt:
sourceFile:
description:
tags: []
sources: []
links:
  ownedBy: []
  claims: []
  cites: []
  describes: []
  supersedes: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: plan / application / deck / onepager / spec / report / contract
status: draft / final / submitted / superseded

`status` 기본값이 가장 약한 `draft` 다. 낸 뒤에 `submitted` 로 올린다.

## 본문을 옮기지 않는다

**이 노트는 문서의 사본이 아니다.** 원본은 그대로 두고 경로만 `sourceFile` 에 적거나
동명 서브폴더에 함께 둔다([[창업-레이아웃]]).

본문을 옮기지 않는 이유는 분량이 아니라 성격이다. 제출용 문서는 심사자를 설득하려고
쓴 글이고, 설득용 문장은 확신의 정도를 지운다. 그 문장을 워크스페이스에 옮기면 과장이
사실로 승격되고, 다음에 AI 가 그 문장을 근거로 읽는다.

## 이 문서가 주장하는 것 - claims

**이 슬롯을 채우는 것이 이 템플릿의 목적이다.** 문서를 처음부터 끝까지 읽으면서
"이건 확인된 건가 아직 우리 생각인가" 를 묻고, 후자를 전부 가설 로 꺼내 여기
건다. 정본이 이쪽이다. 가설 쪽 `claimedIn` 은 적지 않는다.

꺼내는 요령은 셋이다.

- **숫자가 있는 문장**은 거의 전부 주장이다. 시장 규모, 목표 매출, 절감률.
- **"기존 솔루션은 ~하다" 형태**는 경쟁 인식이고 대개 확인된 적이 없다.
- **"고객은 ~를 원한다" 형태**는 고객 가설이다. 인터뷰가 있으면 근거 를 만들고
  없으면 `unvalidated` 로 둔다.

이미 같은 주장을 담은 가설이 있으면 새로 만들지 않고 그것을 건다. 같은 주장이 가설
두 개로 갈리면 검증 상태가 두 곳으로 갈린다.

## 이 문서가 끌어다 쓴 것 - cites

근거로 인용한 근거. `claims` 와 혼동하지 않는다. `claims` 는 이 문서가 **주장한
것**이고 `cites` 는 그 주장을 받치려고 **끌어다 쓴 것**이다. 근거 없이 주장만 있는
문서를 찾는 조회가 이 둘의 차이에서 나온다.

## 무엇을 설명하는가 - describes

이 문서가 다루는 제공물 또는 고객군.

## 제출 전 점검

**제출 버튼을 누르기 전에 이 한 줄을 돌린다.** 이 문서가 주장하는 것 중 아직
`validated` 가 아닌 것을 낸다.

```sh
awk '/^  claims:/{b=1;l=$0;sub(/^  claims:/,"",l);print l;next}
     b&&/^---/{b=0} b&&/^  [a-zA-Z]+:/{b=0} b' "objects/제출문서/{{title}}.md" \
  | grep -oE '\[\[[^]]+' | sed 's/\[\[//' | while IFS= read -r h; do
  grep -qE '^status: validated' "objects/가설/$h.md" 2>/dev/null || echo "unbacked: $h"
done
```

나온 것이 있으면 셋 중 하나를 한다. 근거를 찾아 근거 를 만들거나, 그 문장을
문서에서 빼거나, 수위를 낮춘다. **가설의 상태를 올려서 통과시키지 않는다.** 전체
레시피와 그 이유는 [[창업-린트]] 에 있다.

## 판본 - version

**`version` 이 필수인 이유는 창업 자료의 기본 상태가 여러 벌이기 때문이다.**
지원사업마다 분량과 양식이 달라 같은 문서를 매번 다시 쓴다. 파일명만으로는 어느 것이
최신인지 모르고, `최종_진짜최종` 같은 이름이 그 실패의 흔적이다.

`submittedTo` 가 있으면 `submittedAt` 도 채운다. 어디에 언제 어느 판을 냈는지가 같이
있어야 중복 수혜 판정과 재신청 판정이 선다. 규칙 18 이 이 셋을 본다.

## 대체 관계 - supersedes

새 판에서 옛 판을 가리킨다. 정본이 이쪽이다. 옛 판은 지우지 않고 `status` 를
`superseded` 로 바꾸는 것으로 충분하다. `supersededBy` 슬롯을 두지 않는다.

`grep -rl '\[\[{{title}}\]\]' objects/제출문서/`

## 제출 결과

선정, 탈락, 심사 피드백을 나중에 덧붙인다. 피드백은 다음 판의 가장 좋은 재료이고,
거기서 나온 지적이 대개 근거 없는 주장을 정확히 가리킨다. 이 섹션은 비어 있어도 된다.
