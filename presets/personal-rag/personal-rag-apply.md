---
type: document
title: personal-rag 적용 절차
updated: 2026-10-29
---

# 적용 절차

이 문서는 4단계 중 3단계(프리셋 얹기)다. 사용자가 "personal rag 프리셋으로 ~해줘"
라고 했을 때의 전체 순서는 [[preset-library]] 의 "프리셋 호출 계약"에 있다. 프리셋
찾기(1) -> 프로토콜 설치(2) -> 이 문서(3) -> 기존 파일 정리(4). 4단계의 이동 정책도
그쪽에 있다. 여기서 다시 적지 않는다.

전제: 대상 워크스페이스에 context-protocol 이 이미 적용돼 있다(CONTEXT.md,
`_context-protocol/CONTEXT_GUIDE.md`(6.x 는 루트), memory/, action-log/, _project.md 존재). 없으면
CONTEXT_SETUP.md 로 먼저 프로토콜을 깔고 온다. 프리셋은 프로토콜 위에 얹는
레이어이고 프로토콜을 대체하지 않는다.

작업 도구는 하네스의 호스트 파일 도구다(GUIDE §5, Cowork 에서는 Desktop Commander). (proxy_mount: yes)
마운트는 삭제와 atomic-rename 을 거부하니 임시파일을 만들지 않고 rewrite/append 만 쓴다(GUIDE §4.5). 쓰기는
25~30줄 단위로 쪼갠다.

## Step 0. 사전 확인

1. `_context-protocol/_schema/concept-scheme.md` 를 읽어 top concept 이름을 확인한다. Step 2 의
   `broader` 값이 된다.
2. `_context-protocol/_ontology.md` 를 읽어 기존 개념 트리를 파악한다. `objects`, `people` 등
   이름 충돌이 있는지 본다. 있으면 프리셋 폴더명을 조정하고 이 문서에 기록한다.
3. `memory/MEMORY.md` 와 `_project.md` 를 읽는다(GUIDE §6: 쓰기 전 인덱스와 대상을
   먼저 읽는다).

## Step 1. 폴더 생성

```
objects/  objects/people/  objects/organizations/  objects/projects/
objects/events/  objects/places/  objects/ideas/  objects/artifacts/
object-sets/  object-views/  datasources/
```

`Attachments/` 는 만들지 않는다. 첨부는 관련 객체와 동거한다([[personal-rag-layout]]).
`functions/` 도 만들지 않는다. Dataview 를 쓰지 않으므로 조회 레시피는
[[personal-rag-lint]] 에 둔다.

## Step 2. 개념 노트 11개 작성

각 폴더에 개념 노트를 둔다. frontmatter 형식은 대상 워크스페이스의 기존 개념 노트와
동일하게 맞춘다(`type: concept`, `scheme:`, `pref_label_ko/en`, `broader`,
`definition`).

| 파일 | 개념 id | broader |
|---|---|---|
| `objects/personal-knowledge-graph.md` | personal-knowledge-graph | WS 의 top concept |
| `objects/people/person.md` | person | personal-knowledge-graph |
| `objects/organizations/organization.md` | organization | personal-knowledge-graph |
| `objects/projects/project.md` | project | personal-knowledge-graph |
| `objects/events/event.md` | event | personal-knowledge-graph |
| `objects/places/place.md` | place | personal-knowledge-graph |
| `objects/ideas/idea.md` | idea | personal-knowledge-graph |
| `objects/artifacts/artifact.md` | artifact | personal-knowledge-graph |
| `object-sets/object-set.md` | object-set | personal-knowledge-graph |
| `object-views/object-view.md` | object-view | personal-knowledge-graph |
| `datasources/datasource.md` | datasource | personal-knowledge-graph |

7개 타입 개념 노트의 본문에는 [[personal-rag-object-types]] 의 해당 절(프로퍼티 표,
PK, implements, 허용 출력 링크)을 옮긴다. 개념 노트가 곧 타입 정의를 겸한다.

주의: `broader` 는 개념 하나만 가리킨다. top concept 은 WS 에 정확히 하나여야 하니
`personal-knowledge-graph` 를 새 top 으로 만들지 말고 기존 top 아래에 붙인다.

## Step 3. 스킴 확장 병합

`_context-protocol/_schema/concept-scheme.md` 를 수정한다.

1. 허용 노트 타입 목록에 `Person, Organization, Project, Event, Place, Idea,
   Artifact` 를 추가하고 "lint 상 document 로 취급, broader 없음"을 명기한다.
2. 허용 술어 표 아래에 `links` 행을 추가한다: "Link 맵. 객체 관계. 어휘는
   presets/personal-rag/personal-rag-schema.md".
3. 무결성 규칙에 규칙 7~12([[personal-rag-schema]])을 추가한다.

코어 규칙 1~6 은 건드리지 않는다.

## Step 4. 템플릿 배치

`presets/personal-rag/templates/*.md.tpl` 을 대상 WS 의 `_context-protocol/templates/` 로 복사하고
`.tpl` 을 뗀다. Obsidian 을 쓰지 않는 워크스페이스면 복사를 생략하고 프리셋 폴더의
템플릿을 그때그때 참조해도 된다.

`.md.tpl` 확장자를 쓰는 이유: 템플릿의 frontmatter 는 `type: Person` 같은 값을 갖는데
이를 `.md` 로 두면 lint 가 빈 인스턴스로 오인한다. 비-md 파일은 메타 검사 대상이
아니다(GUIDE §10 유추 기준).

## Step 5. 루트 객체 생성

`objects/people/<본인 이름>.md` 를 Person 템플릿으로 만든다. `tags: [self, root]` 를
단다. 이 노트가 모든 관계, 사건, 산출물의 출발점이 된다.

프리셋의 나머지는 이 노트에서 뻗어나간다. 여기서는 빈 노트만 만들고 속은 다음 스텝에서
채운다.

## Step 5.5. 인테이크 (초기 문답)

[[personal-rag-intake]] 의 질문지를 돌린다. R3 를 마치면 [[personal-rag-variants]] 의
판정표로 용도별 변형을 정하고, 그 변형의 조회 규칙 절을 Step 6-5 에서 `CONTEXT.md` 에
함께 넣는다. 판정은 에이전트가 하고 사용자에게 묻지 않는다.
 AskUserQuestion 라운드로 사용자에게 물어
루트 Person 을 채우고 조직·프로젝트·사람·사건·관념·산출물·외부 출처의 첫 인스턴스를 만든다.

건너뛸 수 있는 스텝이지만 기본은 **돈다.** 원래 설계는 루트 하나만 만들고 GUIDE §12 능동적
축적에 맡기는 것이었는데, 축적은 대화가 일어나야 작동한다. 워크스페이스를 막 받은 사람은
아직 이 에이전트와 대화한 이력이 없어서 그 구간이 비어 있다. 인테이크는 그 부트스트랩
구간만 메우고, 그 뒤는 원래대로 축적에 맡긴다.

사용자가 "나중에"를 고르면 `memory/personal-rag-intake.md` 에 전 라운드 pending 상태로
기록만 남기고 Step 6 으로 간다. 그 파일이 다음 세션의 재개 지점이 된다.

## Step 6. 프로토콜 파일 갱신

1. `_project.md`: `suitability.subjects` 에 새 개념 위키링크를 추가하고,
   `keywords` 에 personal rag, knowledge graph, digital twin 등을 더한다.
   `persona.scope` 에 개인 지식그래프를 운용한다는 한 줄을 넣는다. `updated` bump.
2. `_context-protocol/_ontology.md`: 워크스페이스 레이아웃 트리에 `objects/` 이하를 반영한다.
3. `memory/MEMORY.md`: personal-rag 적용 사실과 진입점(objects/personal-knowledge-graph.md)
   을 인덱스 한 줄로 추가한다.
4. `action-log/<YYYY-MM-DD>.md`: 적용 사실을 엔트리로 append 한다. 형식은
   [[personal-rag-actions]].
5. `CONTEXT.md`(규칙 정본. 포털 `AGENTS.md`, `CLAUDE.md` 에는 적지 않는다): 진입점 목록에 `objects/personal-knowledge-graph.md` 를 한 줄 추가한다.
   프로토콜 8.0 부터 CONTEXT.md 가(5.0 에서 7.x 까지는 CLAUDE.md) 그 워크스페이스의 운영 정본이고 세션이 제일 먼저
   읽는 파일이다. 여기 없는 구조는 다음 세션이 존재를 모른다. 기존 항목 번호를
   재정렬하지 말고 해당 항목 본문에 덧붙이거나 끝에 새 항목으로 붙인다.

이 다섯 가지를 같은 작업에서 처리한다. 구조를 바꿨는데 `_project.md` 를 안 고치면
cross-project import 가 이 워크스페이스를 옛 성격으로 광고한다(GUIDE §6, §12.2).

## Step 7. 검증

[[personal-rag-lint]] 의 점검 목록을 돌린다. 통과 조건: 개념 11개의 broader 가 모두
실재 노트를 가리키고, DAG 이고, top concept 이 여전히 하나이고, 고아 md 가 없고,
`.base`/Dataview 산출물이 새로 생기지 않았고, action-log 에 날짜 폴더가 없다.

## 기존 vault 를 옮겨오는 경우

hsol-info-blob 같은 원본 vault 가 이미 있으면 다음 순서로 번역한다.

1. 인스턴스를 옮긴다. `objects/people/*` -> `objects/people/*` (경로 동일). 
   `objects/concepts/*` -> `objects/ideas/*` (타입 개칭).
2. frontmatter 를 손본다. `type: Concept` -> `type: Idea`, Organization 의
   `type:` 필드 -> `kind:`, `relatedConcepts:` -> `links.relatesTo`.
3. `_ontology/` 의 타입 정의를 각 폴더 개념 노트 본문으로 흡수한다. link-types 등
   나머지는 스킴 확장으로 흡수한다.
4. `action-log/YYYY/YYYY-MM-DD.md` 를 평면 날짜 파일 `action-log/YYYY-MM-DD.md` 로
   꺼낸다. 합치지 않는다. 샤딩 단위(하루)는 원본과 같고 바뀌는 것은 폴더가 없어지는
   것뿐이다. 파일명이 곧 날짜이므로 파일 안에 날짜 헤딩을 두지 않는다. 원본 날짜
   폴더는 마운트에서 지울 수 없으니 그대로 두고 호스트 Finder 에서 정리한다.
5. `functions/` 의 Dataview 쿼리를 [[personal-rag-lint]] 의 grep 레시피로 번역한다.
6. `.base` 파일은 옮기지 않는다.
7. 옮긴 뒤 Step 7 검증을 돌린다.
