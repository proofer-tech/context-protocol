---
type: document
title: personal-rag 스킴 확장 (술어·인터페이스·값 타입·공유 프로퍼티)
updated: 2026-08-18
---

# 스킴 확장

대상 워크스페이스의 `_context-protocol/_schema/concept-scheme.md` 에 병합할 확장이다. 코어 스킴의
허용 노트 타입과 술어에 아래를 **추가**하고, 코어 규칙은 그대로 둔다.

원본에서 `_ontology/link-types/`, `interfaces/`, `value-types/`,
`shared-properties/` 네 폴더에 흩어져 있던 정의를 한 파일로 합쳤다. 술어와 값 타입은
폴더를 소유할 수 없는 스키마이고, 헤드리스 에이전트에게는 한 번 읽어 어휘 전체를
확보하는 편이 낫다.

## 허용 노트 타입 추가

코어의 concept / document / schema / project-descriptor / readme / view / proposal 에
객체 타입 7개를 추가한다.

```
Person, Organization, Project, Event, Place, Idea, Artifact
```

이 7개는 lint 상 **document 와 동일하게** 취급한다. 즉 소속이 결정돼야 한다(개념 폴더
안에 있거나 `subject` 를 갖거나). broader 는 갖지 않는다(개념이 아니다).

원본과 같이 `type: Person` 을 그대로 쓰기 위한 조치다. `type: document` +
`object_type: Person` 으로 쪼갤 수도 있었지만, 키가 하나 늘고 원본 계보와 어긋나며
grep 패턴이 두 줄로 갈라진다.

## 술어 어휘

프로퍼티가 아니라 관계다. frontmatter `links:` 맵 또는 본문 섹션의 위키링크로 쓴다.
`broader` / `related` / `subject` 는 코어 소관이니 객체 관계에 재사용하지 않는다.

### 인적 관계 (Person <-> Person)

| 술어 | 방향 | 기수 | 의미 |
|---|---|---|---|
| knows | 무방향 | n:n | 알고 지냄 |
| familyOf | 무방향 | n:n | 가족. 하위 속성 parent/child/sibling/spouse |
| colleagueOf | 무방향 | n:n | 동료 |
| mentor | Person -> Person | 1:n | 멘토 |

### 소속 / 공간

| 술어 | 방향 | 의미 |
|---|---|---|
| worksAt | Person -> Organization | 일하는 곳. 시간 속성(DateRange) |
| studiedAt | Person -> Organization | 공부한 곳 |
| partOf | 다용도 | 포함 (조직 계층, 지리 포함, 산출물의 프로젝트 소속) |
| livesIn | Person -> Place | 거주 |
| locatedAt | 다용도 -> Place | 위치 |
| collaboratesWith | Organization <-> Organization | 협업 |

### 산출 / 행위

| 술어 | 방향 | 의미 |
|---|---|---|
| created / createdBy | Person <-> Artifact | 만듦 |
| produced | Project -> Artifact | 프로젝트 산출물 |
| participatedIn / hasParticipant | Person <-> Event·Project | 참여 |
| involvesPerson | Event -> Person | 사건 참여자 |
| publishedBy | Artifact -> Organization | 발행처 |

### 인지 / 가치

| 술어 | 방향 | 의미 |
|---|---|---|
| believes | Person -> Idea | 신념/가치관 |
| interestedIn | Person -> Idea | 관심 |
| hasSkill | Person -> Idea(kind=skill) | 보유 스킬 |
| usesIdea | Project -> Idea | 개념/도구 활용 |
| mentionsIdea | Event·Artifact -> Idea | 언급 |
| relatesTo | Idea <-> Idea | 연관 |
| derivedFrom | Idea -> Idea | 파생 |

### 시간 / 인과 / 메타

| 술어 | 방향 | 의미 |
|---|---|---|
| triggers | Event -> Event | 인과 |
| hasEvent | Project -> Event | 마일스톤 보유 |
| references | 다용도 | 참조 |

### 역방향 술어

일부 술어는 명시적 역방향 키를 갖는다. 대상 객체 노트에서 주체로 거는 백링크에 쓴다.
정방향과 역방향을 **양쪽에 다 적지 않는다**. 어느 쪽에 적을지는 "그 사실을 읽으러 갈
노트"를 기준으로 정하고, 필요하면 반대편은 위키링크 백링크로 자연히 잡힌다.

| 역방향 | 정방향 |
|---|---|
| createdBy | created |
| hasParticipant | participatedIn |
| believedBy | believes |
| interestedBy | interestedIn |
| skillOf | hasSkill |
| studiedBy | studiedAt |
| usedBy | usesIdea |
| heldBy | believes(kind=value) |
| hasMember | worksAt |
| ownedBy | created / produced 의 소유자 |

### 보조 술어

의미가 자명해 별도 정의를 두지 않고 어휘에만 등재한다.

`at` (소속/장소 한정), `host` (주최 조직), `event` (연관 사건),
`deck` (연관 발표자료), `project` (부속 노트의 상위 프로젝트),
`relatedObjects` / `relatedViews` (다용도 연결).

## 인터페이스 (추상 타입)

여러 타입이 공통으로 갖는 구조. 폴더를 만들지 않고 이 표로만 존재한다. 각 객체 타입
개념 노트의 `implements:` 에 이름을 적는다.

### HasIdentity

구현: 7종 전부. "이 객체가 누구/무엇인지" 식별 가능하게 만든다.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `name` 또는 `slug` | O | PK |
| `aliases` |  | 이름 변형(nameVariant)만 |
| `identifiers` |  | 식별자 레지스트리 (아래) |
| `webPresence` |  | 소유 도메인/URL (아래) |
| `tags` |  | 자유 분류 |
| `description` |  | 짧은 설명 |

### Temporal

구현: Person, Project, Event, Artifact. 타임라인 정렬/필터의 기준이 된다.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `startDate` 또는 동등 필드 | O | 시작 (Person=birthDate, Artifact=createdAt) |
| `endDate` 또는 동등 필드 |  | 종료 (비움 = 진행중/생존) |

### Located

구현: Organization, Event. 장소 기준 조회의 인덱싱 키다.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `place` 또는 `headquarters` | O | Place 참조 |

## 값 타입

### DateRange

시작과 끝의 묶음. 재직 기간, 프로젝트 기간, 여행 기간에 반복 사용한다.

```yaml
period:
  start: 2024-01-01
  end:            # 비움 = 진행 중
```

### IdentifierStatus

식별자와 웹 프레즌스의 생애 상태 enum.

- `current` 현행 - 지금 이 객체가 쓰는/소유한 것
- `past` 과거 - 한때 썼으나 폐기/중단 (deprecated/archived/retired 포괄)
- `misattributed` 타인오귀속 - 이 객체 것이 아님. 재발 오답 방지용으로 명시 기록

규칙: 상태가 바뀌면 값을 지우지 말고 상태만 갱신한다. 식별자 이력 자체가 자산이다.
`misattributed` 항목은 반드시 실제 소유자를 함께 적는다.

## 공유 프로퍼티

여러 타입이 동일한 의미로 쓰는 프로퍼티.

| 이름 | 타입 | 사용 | 설명 |
|---|---|---|---|
| `tags` | string[] | 전체 | 자유 분류 |
| `description` | text | 전체 | 짧은 설명 |
| `updated` | date | 전체 | 마지막 갱신 (GUIDE §6 이 bump) |
| `sources` | url[] | 전체 | 출처/근거 |
| `confidence` | enum | 전체 | low / medium / high |
| `identifiers` | struct[] | Person·Organization·Project·Artifact | 이 객체를 가리키는 식별자 |
| `webPresence` | struct[] | Person·Organization·Project | 이 객체가 소유·운영하는 도메인 |

### identifiers (4축 + 값)

| 축 | 값 |
|---|---|
| `value` | 식별자 문자열 |
| `kind` | nameVariant / handle / email / account |
| `context` | 플랫폼·서비스·시기 |
| `status` | IdentifierStatus |
| `source` | 검증 근거 |

kind 정의: **nameVariant** 같은 대상을 가리키는 다른 이름(영문 표기, 예명, 로마자 순서).
**handle** 플랫폼 위의 사용자명, `(플랫폼, 핸들)` 쌍이 본질. **email** 이메일 주소.
**account** 3rd-party 서비스에 보유한 계정(소유 도메인이 아님).

표현: 식별자 1~2개면 frontmatter `aliases:` + 본문 한두 줄. 많으면 본문에
`## 정체성·계정 레지스트리` 섹션 + 5열 표. frontmatter `aliases:` 에는
nameVariant 만 넣고 handle/email/account 는 표로 뺀다.

### webPresence

| 축 | 값 |
|---|---|
| `url` | 도메인/주소 |
| `status` | IdentifierStatus |
| `role` | homepage / blog / newsroom / service / landing |
| `note` | 비고 |
| `source` | 검증 근거 |

### 귀속 규칙 (전 객체 적용)

1. 식별자는 그것이 가리키는 **객체 본인의 노트**에 산다. 사람의 핸들은 그 사람 노트,
   조직 계정은 그 조직 노트. 흩뿌리지 않는다.
2. 도메인은 **그 도메인이 대표하는 객체**에 산다. 프로젝트 서비스 주소 -> 프로젝트
   노트, 회사 도메인 -> 조직 노트, 개인 사이트 -> 사람 노트. 사람 노트는 프로젝트/조직
   도메인을 롤업 위키링크로만 가리킨다.
3. 3rd-party 서비스에 계정만 있는 경우는 webPresence 가 아니라 identifiers 의
   `account` 로 기록한다.
4. 모든 항목에 `status` 와 `source` 를 단다. 폐기해도 삭제하지 않고 상태만 갱신하고,
   오귀속은 `misattributed` + 실제 소유자 명시.

## 무결성 규칙 추가

코어 lint 규칙 1~6 에 더한다. 점검 방법은 [[personal-rag-lint]].

7. 객체 인스턴스의 `type:` 은 허용 노트 타입에 등재된 값이어야 한다.
8. 객체 인스턴스는 필수 프로퍼티(PK, 각 타입의 O 표시)를 모두 갖는다.
9. `links:` 와 본문의 모든 위키링크는 실재하는 노트를 가리킨다.
10. 술어는 이 문서의 어휘에 있는 것만 쓴다. 새 술어는 표에 추가하고 나서 쓴다.
11. 정방향과 역방향 술어를 같은 사실에 대해 양쪽 노트에 동시에 적지 않는다.
12. 객체 인스턴스는 `broader` 를 갖지 않는다. 개념이 아니다.
