---
type: schema
title: context-protocol concept scheme (v4)
scheme_id: context-protocol
top_concept: "[[context-infrastructure]]"
---

# Concept scheme (controlled vocabulary, v4)

허용 타입/술어/규칙을 사람이 읽고 lint 가 검사합니다. v4는 구조 우선 + 원본 동거.

## 허용 노트 타입

- concept : 개념 노드. 폴더 개념은 그 폴더 안 `<개념id>.md`, 추상 개념은 `_concepts/`.
- document : 콘텐츠 원본. 별도 노트가 아니라 원본 파일 자체(frontmatter 보유).
- schema : 이 파일.
- project-descriptor : 워크스페이스 루트의 `_project.md`. cross-project import 발견 마커.
  고정경로 루트 파일이라 자기분류 대상(subject 요구 예외). 스키마/규칙은 GUIDE §11.
- readme, view, proposal : 문서/뷰/제안.

## 허용 술어 (frontmatter 키)

| 술어 | 타입 | 규칙 |
|---|---|---|
| broader | Link (개념 1개) | top concept 외 모든 concept에 1개 필수 |
| related | Link 리스트 | 선택, 대칭 관계 |
| subject | Link 리스트 | document 소속. 위치(개념 폴더)로 충족되면 생략 가능 |
| pref_label_ko / pref_label_en | text | concept에 권장 |
| definition | text | concept에 권장 |
| backend_id | text | 프로파일 문서 `_context-protocol/backends/<backend_id>.md` 에 필수이고 파일명과 같아야 한다. 폴더 개념 노트 `storage-backend.md` 는 제외 |
| harness_id | text | 프로파일 문서 `_context-protocol/harnesses/<harness_id>.md` 에 필수이고 파일명과 같아야 한다. 폴더 개념 노트 `agent-harness.md` 와 설계 문서는 제외 |
| canon_note | Link (1개 이상) | 원 기록 document 에만. 주제별 정본이 사는 개념 노트를 가리킨다. 이 키가 있으면 원 기록이고, 본문 H1 아래 정본 우선 문장을 둔다. 분해 검토 신호에서 빠진다 |
| grounded_on | Link 리스트 | document 에만. 이 정리 노트가 기대어 쓰인 원본. 비-md 원본은 확장자까지 쓴 위키링크. 원본이 노트보다 나중에 바뀌면 integrity-lint 가 근거 drift 검토 신호를 띄운다 |
| grounded_checked | date (YYYY-MM-DD) | grounded_on 이 있는 document 에만. 노트는 고치지 않고 근거 원본과 대조만 한 날. drift 신호는 updated 와 이 값 중 늦은 날을 기준으로 본다 |
| supersedes | Link 리스트 | document 에만. 이 판이 대체한 이전 판. 대체된 판은 고치지 않는다. 지금 유효한 판은 이 관계로 정하고 수정 시각이나 파일명으로 정하지 않는다. 절차는 `_context-protocol/_ontology.md` "판이 바뀌는 문서" |
| trust_tier | enum `verified` / `sourced` / `unverified` | document 에만, 선택(8.3). 이 문서를 얼마나 믿어도 되는가. `verified` 원본이나 책임자가 확인함, `sourced` 출처는 있으나 확인 전, `unverified` 출처가 불분명하거나 추정. 높은 순서는 verified, sourced, unverified. `sourced` 이하 문서로 답할 때는 그렇다고 밝힌다(GUIDE §3). 키가 없는 문서는 판정하지 않는다. 정리 노트의 등급은 `grounded_on` 원본 중 이 키가 있는 것의 가장 낮은 등급을 넘지 못한다. 넘으면 integrity-lint 가 신뢰 역전 검토 신호를 띄운다 |
| derived_from | text | 기계 변환본 document 에만. 같은 폴더에 있는 원본 파일의 이름. 이 키가 있으면 도구가 만든 사본이라 손으로 고치지 않고, 원본이 바뀌면 다시 만든다. 분해 검토 신호에서 빠진다. 지금 쓰는 곳은 HWP 변환기(GUIDE §4.10) |

v3의 `source` 키는 폐기됐다. 원본이 곧 문서라 참조 경로가 없다.

위 두 목록(허용 노트 타입, 허용 술어)은 고정 목록이 아니라 확장 가능한 어휘다. 새
종류나 새 관계가 필요하면 스키마 우선으로 여기 먼저 등재하고 나서 쓴다. 절차는
`_context-protocol/_ontology.md` 의 "어휘를 늘릴 때". 프리셋이나 도메인 레이어의
확장 정의는 그 레이어 안에 두고 여기에는 등재만 한다. 코어를 도메인 어휘로 채우면
워크스페이스마다 코어가 갈라진다.

## 분류 메커니즘 (소속 결정)

1. 위치: 개념 폴더 `X/` 안의 파일은 개념 X 소속. 폴더 중첩 = broader.
2. frontmatter: md 의 `subject` 로 명시. 고정경로 파일에 필수, 다중 소속에도.
3. 유추: 비-md 파일은 메타 없이 파일명 + 폴더 + 참조 md 로 읽는다.

## 무결성 규칙 (integrity-lint.md 가 검사, _deprecated_* 제외)

1. 모든 concept는 broader가 정확히 1개 (top concept 제외).
2. broader / subject / related / canon_note 의 링크는 반드시 존재하는 노트를 가리킨다.
   grounded_on / supersedes 의 링크는 존재하는 파일(비-md 포함)을 가리킨다.
3. 모든 문서 md는 소속이 결정돼야 한다: 개념 폴더 안에 있거나(위치) subject가 있거나.
4. broader 그래프는 순환하지 않는다 (DAG).
5. top concept는 이 스킴에 정확히 1개.
6. project-descriptor(`_project.md`)는 broader/subject 소속 검사(규칙 3) 대상이 아니다
   (자기분류). 대신 `suitability.subjects` 의 각 링크가 실재하는 concept 노트를 가리켜야 한다.

## 분류할 곳이 없을 때 (구조 생성 원칙)

맞는 개념 폴더가 없다는 것은 분류를 포기할 이유가 아니라 개념을 추가할 신호다.
어떤 파일도 "딱 맞는 곳이 없어서" 틀린 개념 폴더에 놓이지 않는다. 없으면 만든다.
사용자 승인을 기다리지 않고, 만든 사실과 이유를 경로로 보고한다.

새로 만든 개념은 생성 즉시 위 무결성 규칙 1~5 를 만족해야 한다. 즉 broader 1개,
링크가 실재 노트를 가리킴, DAG 유지, top concept 는 여전히 하나. 절차와 판단 순서,
개념 폭발 제동은 `_context-protocol/_ontology.md` 의 "둘 곳이 없으면 만든다".

이것은 lint 로 기계 검사되는 규칙이 아니다. "이 파일이 틀린 폴더에 있나"는 자동으로
판정할 수 없다. 그래서 번호 붙은 무결성 규칙이 아니라 행동 원칙으로 둔다.

## 본문 절 규약 (출처 구분)

대화에서 나온 결정을 담는 문서는 본문을 출처로 가른다. frontmatter 술어를 쓰지 않고
절로 둔다. 한 문서에 확정과 제안이 섞이는 일이 흔해서 문서 단위 값 하나로는 그 섞임을
적을 수 없다.

| 절 | 담는 것 |
|---|---|
| `## 확정` | 사용자가 말했거나 명시적으로 채택한 것. 결정일을 알면 붙인다 |
| `## 제안 (미확정)` | 에이전트가 제안했고 사용자가 아직 채택하지 않은 것 |
| `## 열린 질문` | (선택) 아직 누구도 답하지 않은 것 |

- 제안이 채택되면 확정 절로 옮겨 결정일을 적고 결정이력에 한 줄 남긴다.
- 사용자가 기각한 제안은 제안 절에서 뺀다. 기각이 방향을 정했으면 결정이력에 기각으로
  한 줄 남긴다. 다른 안이 채택돼 밀려난 제안도 기각과 같게 다룬다.
- 사용자가 반응 없이 지나간 제안은 남긴다. 제안 절은 사용자가 아직 고를 수 있는 거리의
  목록이다. 사용자가 에이전트의 수치나 제안을 조건문으로 인용한 것("3~4천 원이면")은
  채택으로 치지 않는다.
- 에이전트가 새로 보탠 사실(조사 결과, 추정)은 확정 절에 넣지 않는다. 사용자가 확인하기
  전까지 제안 절에 출처와 함께 둔다. 확정 절 문장을 에이전트가 다듬어도 출처는 사용자다.
- 결정이력과 용어처럼 확정된 것만 담는 문서는 이 절들을 두지 않는다.
- 제안이 없으면 제안 절을 두지 않는다. 대화에서 나오지 않은 참고 지식 문서(정책, 절차,
  외부 자료 요약)는 이 규약의 대상이 아니다.
- 주제 안의 소절은 출처 절 아래 H3 로 둔다. 출처가 한쪽뿐인 소절(예: 규제와 위험)은
  H2 로 둬도 된다.
- 절 이름은 워크스페이스 언어를 따른다. 영문은 `## Confirmed`, `## Proposed (not
  adopted)`, `## Open questions`. 분해 검토 신호는 두 표기를 다 출처 절로 본다.

## 검토 신호 (오류가 아닌 것)

아래는 integrity-lint 가 띄우지만 통과 여부에 넣지 않는 신호다. 판정은 사람이나
에이전트가 정의 시험으로 한다. 번호 붙은 무결성 규칙과 섞지 않으려고 따로 둔다.

- 분해 검토: 하위 개념 폴더가 없는 개념 폴더 안의 md 가 200줄을 넘거나, 출처 절을 뺀
  H2 가 5개를 넘는다. `_context-protocol/`, `memory/`, action-log, `_deprecated_*`, 원 기록
  (`canon_note` 보유), 기계 변환본(`derived_from` 보유)은 제외한다. 정의 시험과 분해 절차는 `_context-protocol/_ontology.md`
  의 "쓰기 전에 분해한다".
- 근거 drift: `grounded_on` 이 가리키는 원본의 수정 시각이 노트의 `updated` 와
  `grounded_checked` 중 늦은 날보다 뒤다. 동기화로도 수정 시각이 바뀌므로 오탐이 난다.
  판정은 원본을 열어 노트와 대조해서 한다. 절차는 `_context-protocol/_ontology.md` 의
  "정리 노트의 근거".
- 신뢰 역전: `trust_tier` 가 있는 document 의 등급이, `grounded_on` 원본 중 `trust_tier` 가 있는
  것의 가장 낮은 등급보다 높다. 정리하는 과정이 신뢰를 올려 주지 않는다는 원칙의 점검이다. 노트의
  등급을 낮추거나, 원본을 확인해 원본 쪽 등급을 올린다. 키가 없는 문서는 양쪽 다 대상이 아니다.

## 관계 방향 정책

broader 만 작성한다. narrower 는 절대 손으로 쓰지 않는다.
narrower가 필요하면 "broader가 나를 가리키는 개념들"을 뷰가 역계산한다.
