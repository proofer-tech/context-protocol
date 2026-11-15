---
type: document
title: personal-rag 대상 워크스페이스 레이아웃
updated: 2026-10-29
---

# 대상 워크스페이스 레이아웃

이 프리셋을 적용한 워크스페이스(이하 WS)가 갖는 구조다. 프로토콜 부속물은 6.0 부터
모든 워크스페이스에서 같은 이름 `_context-protocol/` 에 모인다.

```
WS/
  CONTEXT.md                       규칙 정본이자 세션 진입 (프로토콜 소관)
  AGENTS.md, CLAUDE.md             포털 (프로토콜 소관, 프리셋이 손대지 않음)
  _project.md                      project-descriptor. suitability.subjects 에 객체 타입 개념 추가
  _context-protocol/
    CONTEXT_GUIDE.md               프로토콜 정본 (7.0 부터 클러스터 안, 6.x 는 루트)
    _ontology.md                   구조 우선 온톨로지 readme. 아래 트리를 반영
    _schema/concept-scheme.md       코어 스킴. 여기에 프리셋 확장을 병합
    _concepts/                      대응 폴더 없는 추상 개념
  memory/                          LLM 메모리 레이어 (프로토콜 소관)
  action-log/
    action-log.md                  개념 노트
    2026-08-18.md                  날짜 파일(하루 하나). 액션 어휘는 personal-rag-actions 참조
  objects/
    personal-knowledge-graph.md    폴더 개념. broader = WS 의 top concept
    people/
      person.md                    폴더 개념 (타입 정의 겸용). broader = personal-knowledge-graph
      임한솔.md                    인스턴스. 위치로 분류
      <부속물 많은 사람>/
        <같은 이름>.md             인덱스 노트(PK)를 폴더 안에 동명으로
        <첨부·부속 노트>
    organizations/
      organization.md
    projects/
      project.md
    events/
      event.md
    places/
      place.md
    ideas/
      idea.md
    artifacts/
      artifact.md
  object-sets/
    object-set.md                  폴더 개념. broader = personal-knowledge-graph
    <집합>.md                      큐레이트 모음 또는 필터 명세
  object-views/
    object-view.md                 폴더 개념. broader = personal-knowledge-graph
    <뷰>.md                        포트폴리오 요약, 타임라인, 자기소개 등 출력물
  datasources/
    datasource.md                  폴더 개념. broader = personal-knowledge-graph
    <출처>.md                      외부 출처 인덱스 (원문 비복제)
```

## 분류가 성립하는 방식

1. **위치(1순위)**: `objects/people/` 안의 md 는 개념 person 소속이다. frontmatter 에
   `subject` 를 적지 않아도 된다. 파일을 다른 타입 폴더로 옮기면 그것이 재분류다.
2. **폴더 중첩 = broader**: `objects/people/` 이 `objects/` 안에 있으므로 person 의
   broader 는 personal-knowledge-graph 다. 개념 노트 frontmatter 에 명시한다.
3. **frontmatter**: 한 인스턴스가 두 타입에 걸치는 예외적 경우에만 `subject` 로 다중
   소속을 적는다. 기본은 위치 하나로 끝낸다.
4. **비-md**: pdf, pptx, xlsx, 이미지는 메타를 붙이지 않는다. 관련 객체의 서브폴더에
   두고 인덱스 노트에서 위키링크로 언급한다.

## 타입 폴더 = 개념 노트가 겸하는 두 역할

`objects/people/person.md` 한 파일이 (a) 폴더 person 의 개념 노트이고 동시에
(b) Person 객체 타입의 정의(프로퍼티 표, PK, 허용 링크)다. 원본에서 분리돼 있던
`_ontology/object-types/Person.md` 와 `objects/people/` 가 여기서 합쳐진다.

이렇게 두는 이유: 에이전트가 `objects/people/` 를 읽으면 스키마와 인스턴스가 같은
컨텍스트에 들어온다. 타입 정의를 확인하러 다른 트리로 점프하지 않는다.

정의 본문의 표준 형태는 [[personal-rag-object-types]] 에 타입별로 다 적혀 있다.
적용 시 그 내용을 각 개념 노트 본문으로 옮긴다.

## objects/ 를 남긴 이유

`people/` 를 WS 루트에 바로 두지 않고 `objects/` 아래 둔다. 그러면 `objects/` 폴더가
개념 personal-knowledge-graph 를 담당해서, 7개 타입의 broader 가 한 노드로 모인다.
루트에 흩으면 타입 7개가 각각 WS top concept 에 직결돼 그래프가 평평해지고, 프리셋을
적용한 부분과 워크스페이스 고유 개념이 구분되지 않는다.

부수 효과로 원본 `objects/people/` 경로 모양이 유지돼 계보 대조가 쉽다.

## 부속물이 쌓이는 객체의 서브폴더 규칙

기본은 `objects/<type>/<PK>.md` 단일 파일이다. 부속 자료(첨부, 분석 노트, 회차별
기록)가 여러 개 쌓이면 **같은 이름의 서브폴더**를 만들고 인덱스 노트(PK)를 그 안에
**같은 파일명으로** 둔다. 위키링크는 파일명으로 해석되니 기존 링크는 안 깨진다.

```
objects/projects/엘리스-QA-자동화-트랙-6기-코치/
  엘리스-QA-자동화-트랙-6기-코치.md    인덱스(PK), 프로젝트의 정본
  직무특강-사전질문-분석.md            부속 노트. frontmatter project: 로 상위 명시
  직무특강-슬라이드.pptx               비-md 첨부. 위치로 분류
```

주의: 이 서브폴더는 v4 규칙상 개념 폴더가 아니다. 개념 노트를 두지 않으며, 안의
파일은 상위 타입 폴더가 아니라 **이 서브폴더 위치**로 분류된다. lint 가 고아로 잡지
않게 하려면 부속 md 에 `subject: ["[[<type>]]"]` 를 적는다. 인덱스 노트는 파일명이
곧 PK 이므로 예외 없이 `subject` 를 적는다. 상세는 [[personal-rag-lint]].

## 프리셋이 건드리지 않는 것

`CONTEXT.md` 의 프로토콜 항목, 포털(`AGENTS.md`, `CLAUDE.md`), `CONTEXT_GUIDE.md`, `memory/`, action-log 의 시간축 규칙은 전부
프로토콜 소관이다. 프리셋은 `objects/`, `object-sets/`, `object-views/`,
`datasources/` 를 추가하고, `_project.md` 의 suitability 와 `_schema/` 에 확장을
병합하고, action-log 에 액션 어휘를 얹는 것까지만 한다.
