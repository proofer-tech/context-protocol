---
type: document
title: personal-rag 객체 타입 7종
updated: 2026-08-18
---

# 객체 타입 7종

각 타입은 대상 워크스페이스에서 `objects/<folder>/<concept-id>.md` 개념 노트가 된다.
그 노트의 frontmatter 는 개념 노트 규약(type/scheme/pref_label/broader/definition)을
따르고, 본문에 여기 적힌 타입 정의(프로퍼티 표, PK, 인터페이스, 허용 출력 링크)를
옮긴다. 개념 노트 자체는 스키마이고, 같은 폴더의 나머지 md 가 인스턴스다.

인스턴스 frontmatter 는 `type: <ObjectType>` 을 그대로 쓴다. 이 7개 값은 프리셋
스킴 확장이 허용 노트 타입으로 등재하며 lint 상 document 로 취급된다
([[personal-rag-schema]]).

| 타입 | 폴더 | 개념 id | PK | 구현 인터페이스 |
|---|---|---|---|---|
| Person | `objects/people/` | person | name | HasIdentity, Temporal |
| Organization | `objects/organizations/` | organization | name | HasIdentity, Located |
| Project | `objects/projects/` | project | slug | HasIdentity, Temporal |
| Event | `objects/events/` | event | slug | HasIdentity, Temporal, Located |
| Place | `objects/places/` | place | name | HasIdentity |
| Idea | `objects/ideas/` | idea | name | HasIdentity |
| Artifact | `objects/artifacts/` | artifact | slug | HasIdentity, Temporal |

PK 는 파일명이다. WS 안에서 유일해야 하고 한글도 된다. `name` PK 타입은 파일명이
곧 이름, `slug` PK 타입은 파일명이 URL 친화 식별자다.

## Person

실재하는 한 사람. 워크스페이스의 루트 객체(본인)도 이 타입의 인스턴스다. 가족, 친구,
동료, 인터뷰 대상까지 모든 인물이 여기 들어간다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 이름 (PK) |
| `aliases` | string[] |  | 이름 변형만 (nameVariant). 핸들/이메일은 identifiers 로 |
| `birthDate` | date |  | 생년월일 |
| `gender` | string |  | 성별 정체성 |
| `nationality` | string |  | 국적 |
| `currentLocation` | -> Place |  | 현재 거주지 |
| `bio` | text |  | 한 줄 소개 |
| `tags` | string[] |  | family / friend / colleague / mentor 등 |
| `firstMet` | date |  | 처음 만난 날 (본인 외) |

허용 출력 링크: knows -> Person, familyOf -> Person, colleagueOf -> Person,
worksAt -> Organization, studiedAt -> Organization, livesIn -> Place,
created -> Artifact, participatedIn -> Event/Project, believes -> Idea,
interestedIn -> Idea, hasSkill -> Idea(kind=skill)

## Organization

회사, 학교, 단체, 커뮤니티, 팀. 사람이 소속되거나 협업하는 모든 조직.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 조직명 (PK) |
| `kind` | enum |  | company / school / community / nonprofit / team |
| `industry` | string |  | 산업/도메인 |
| `foundedAt` | date |  | 설립일 |
| `dissolvedAt` | date |  | 해체일 |
| `homepage` | url |  | 공식 웹사이트 |
| `headquarters` | -> Place |  | 본사/주 위치 |
| `description` | text |  | 설명 |

원본은 이 필드를 `type:` 으로 뒀으나 `type` 은 노트 타입 키로 예약돼 있어 `kind` 로
바꿨다. 인스턴스 frontmatter 의 `type: Organization` 과 충돌하기 때문이다.

허용 출력 링크: locatedAt -> Place, partOf -> Organization,
collaboratesWith -> Organization, hasMember -> Person

## Project

목적과 기간을 가진 작업 단위. 개인 프로젝트, 회사 프로젝트, 학습 프로젝트 전부.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | URL 친화 식별자 (PK) |
| `name` | string | O | 프로젝트명 |
| `status` | enum | O | planning / active / paused / done / archived |
| `startDate` | date |  | 시작일 |
| `endDate` | date |  | 종료일 (비움 = 진행중) |
| `role` | string |  | 본인의 역할 |
| `org` | -> Organization |  | 진행 조직 |
| `stack` | string[] |  | 기술 스택 / 사용 도구 |
| `outcome` | text |  | 결과 요약 |
| `links` | url[] |  | 외부 링크 (GitHub, 데모) |

허용 출력 링크: hasParticipant -> Person, partOf -> Organization,
produced -> Artifact, usesIdea -> Idea, hasEvent -> Event(마일스톤),
ownedBy -> Person

부속 자료가 쌓이면 동명 서브폴더 규칙을 쓴다([[personal-rag-layout]]).

## Event

특정 시점/기간에 일어난 사건. 생애 마일스톤(졸업, 입사, 이사), 만남, 발표, 여행,
위기, 결정의 순간.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 사건명 |
| `category` | enum |  | milestone / meeting / decision / travel / crisis / launch |
| `startDate` | datetime | O | 시작 시각 |
| `endDate` | datetime |  | 종료 시각 (단일 시점이면 비움) |
| `place` | -> Place |  | 장소 |
| `summary` | text |  | 요약 |
| `significance` | text |  | 본인에게의 의미 |

허용 출력 링크: involvesPerson -> Person, locatedAt -> Place, partOf -> Project,
triggers -> Event(인과), mentionsIdea -> Idea

Event 객체와 action-log 엔트리는 다르다. 로그는 모든 변경의 한 줄 흔적이고, Event 는
독립 의미를 갖는 사건만 승격시킨 객체다. 판단 기준은 [[personal-rag-actions]].

## Place

지리적 공간. 국가, 도시, 동네, 건물, 방, 장소(카페, 사무실), 여행지.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 장소명 (PK) |
| `kind` | enum |  | country / city / district / building / room / venue |
| `coordinates` | string |  | "lat,lng" |
| `address` | string |  | 주소 |
| `parentPlace` | -> Place |  | 상위 장소 (서울 -> 한국) |
| `description` | text |  | 설명 |

허용 출력 링크: partOf -> Place (지리적 포함)

`parentPlace` 프로퍼티와 `partOf` 링크는 같은 사실을 가리킨다. 하나만 쓴다.
권장은 `partOf` 링크이고 `parentPlace` 는 원본 호환용으로 남긴다.

## Idea

추상적 관념. 가치관, 신념, 관심사, 보유 스킬, 학습 주제. 물리적 실체가 없는 것들.

원본의 `Concept` 타입이다. v4 에서 concept 은 분류 노드를 뜻하므로 이름만 바꿨다.
스킴 확장에 `Concept` 을 별칭으로 등재하지 않는다. 두 의미가 섞이는 것이 개칭의 이유
이므로 별칭을 두면 개칭이 무의미해진다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 관념명 (PK) |
| `kind` | enum | O | value / belief / interest / skill / topic / tool |
| `level` | enum |  | (kind=skill) novice / intermediate / advanced / expert |
| `since` | date |  | 보유/관심 시작 시점 |
| `description` | text |  | 설명 |

허용 출력 링크: relatesTo -> Idea, derivedFrom -> Idea, 그리고 역방향 백링크
believedBy / interestedBy / skillOf / heldBy / usedBy -> Person

`relatedConcepts` 프로퍼티는 `relatesTo` 링크로 흡수했다. 같은 사실을 프로퍼티와
링크 두 곳에 적으면 갱신이 갈라진다.

## Artifact

산출물. 글, 코드, 디자인, 발표자료, 영상, 사진, 작품. 본인이 만들었거나 깊이 관여한
결과물.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 제목 |
| `kind` | enum | O | post / code / design / talk / video / photo / artwork / deck |
| `createdAt` | date |  | 생성일 |
| `publishedAt` | date |  | 공개일 |
| `url` | url |  | 외부 URL |
| `format` | string |  | md / pdf / mp4 / png |
| `summary` | text |  | 요약 |
| `tags` | string[] |  | 자유 태그 |

허용 출력 링크: createdBy -> Person, partOf -> Project,
publishedBy -> Organization, references -> Artifact/Idea/Event,
host -> Organization, event -> Event, deck -> Artifact(kind=deck)

산출물의 실제 파일(pdf, pptx, 이미지)은 이 노트와 같은 폴더 또는 동명 서브폴더에
둔다. 비-md 라 메타를 붙이지 않고 이 노트가 위키링크로 가리킨다.

## 7종에 없는 것이 나오면 타입을 만든다

핵심 7종은 출발점이지 울타리가 아니다. 어떤 대상이 7종 중 어디에도 정확히 맞지
않으면, 가장 가까운 타입에 밀어넣지 말고 **새 타입 폴더를 만든다**. 프로토콜의 구조
생성 원칙(`_context-protocol/_ontology.md` "둘 곳이 없으면 만든다")이 프리셋 안에서 이렇게 구체화
된다. 억지로 끼워넣으면 위치가 곧 분류라서 그 대상이 영구히 틀린 종류로 읽힌다.

판단 순서는 프로토콜과 같다. 정확히 맞는 기존 타입 -> 기존 타입의 특수화(하위) ->
새 타입 폴더 -> 폴더를 가질 만큼 인스턴스가 없으면 추상 개념.

억지 분류의 신호: "Person 은 아니지만 사람 폴더에", "Artifact 로 치자", "Idea 의
kind 를 하나 늘려서". kind enum 을 늘려 해결하려는 충동은 특히 흔한데, kind 는 **같은
종류 안의 갈래**를 나누는 축이다. 종류 자체가 다르면 kind 가 아니라 타입이다.

### 예시: 반려동물 (거북이를 어디 둘까)

임한솔의 반려 거북이를 넣으려 한다. 7종을 훑어보면 어디에도 맞지 않는다.

- Person: 아니다. 사람이 아니다. 여기 넣으면 관계망 질의("아는 사람")가 오염된다.
- Idea: 아니다. 물리적 실체가 있다.
- Artifact: 아니다. 만든 결과물이 아니다.
- Place: 아니다. 장소가 아니다(수조는 Place 지만 거북이는 아니다).
- Event: 아니다. 입양이 Event 고 거북이는 그 사건의 참여자다.

그러면 새 타입을 만든다. `Pet`, 폴더 `objects/pets/`, 개념 id `pet`,
개념 노트 `objects/pets/pet.md`, broader `personal-knowledge-graph`.

```yaml
# objects/pets/pet.md 의 타입 정의 (개념 노트 본문)
type: Pet
plural: Pets
primaryKey: name
implements: [HasIdentity, Temporal]
```

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 이름 (PK) |
| `species` | string | O | 종 (거북이, 개, 고양이) |
| `breed` | string |  | 품종 (붉은귀거북 등) |
| `birthDate` | date |  | 태어난 날 (추정 가능) |
| `adoptedAt` | date |  | 함께 살기 시작한 날 |
| `diedAt` | date |  | 사망일 (Temporal 의 종료 시점) |
| `description` | text |  | 설명 |

허용 출력 링크: `keptBy` -> Person(보호자, `keeps` 의 역), `livesIn` -> Place(수조,
집), `partOf` -> Event(입양 사건). Person 쪽에는 `keeps` -> Pet 를 추가한다.

폴더 이름을 `pets` 로 하고 개념 id 를 `pet` 으로 둔 이유는 기존 7종과 같은 규약이다
(폴더는 복수, 개념 id 와 타입명은 단수). `반려동물/` 처럼 한글 폴더도 가능하지만,
기존 타입 폴더가 전부 영문 복수형이라 일관성을 택했다. 인스턴스 파일명은 한글이어도
된다(`objects/pets/거북이.md`).

이 예시는 프리셋의 핵심 타입에 Pet 을 추가하는 것이 아니다. 확장이 어떻게 일어나야
하는지 보여주는 것이고, 실제로 Pet 이 필요한 워크스페이스가 프로토콜의 구조 생성·어휘
확장 절차와 아래 프리셋 델타를 합쳐 만든다.

## 타입 추가: 프리셋 고유 델타

절차의 정본은 프로토콜이다. `_context-protocol/_ontology.md` 의 두 절을 따른다. "둘 곳이 없으면
만든다"(폴더 신설과 같은 작업 의무 4개)와 "어휘를 늘릴 때"(노트 타입·술어 등재,
스키마 우선). 여기 다시 적지 않는다. 같은 절차를 두 곳에 적으면 반드시 갈라진다.

이 프리셋에서만 추가로 지켜야 하는 것:

1. 인스턴스 폴더는 `objects/<복수형>/` 아래에 두고, 개념 노트는 그 안에 단수형 개념
   id 로 둔다(`objects/pets/pet.md`). `broader` 는 `[[personal-knowledge-graph]]`.
2. 개념 노트 본문에 프로퍼티 표, PK, `implements`, 허용 출력 링크를 적는다. 이 노트가
   폴더 개념 노트와 타입 정의를 겸한다(원본의 `_ontology/object-types/` 를 대체).
3. 새 술어는 [[personal-rag-schema]] 의 술어 표에 행을 추가한다. 코어
   concept-scheme 에는 타입명 등재만 하고 술어 정의는 넣지 않는다.
4. `templates/<타입>.md.tpl` 을 추가하고 [[object-template]] 의 수록 목록을 갱신한다.

원본에 있었으나 이 프리셋이 뺀 Mentee, NewsArticle 이 필요하면 이 절차로 되살린다.
Mentee 는 Person 의 특수화(멘토링 맥락 프로퍼티 추가), NewsArticle 은 Artifact 의
특수화(외부 저자 + 발행처)로 두는 것이 계보에 맞다.
