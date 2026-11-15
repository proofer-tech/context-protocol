---
type: document
title: team-ops 객체 타입 8종
updated: 2026-09-10
---

# 객체 타입 8종

각 타입은 대상 워크스페이스에서 `objects/<folder>/<concept-id>.md` 개념 노트가 된다.
그 노트의 frontmatter 는 개념 노트 규약을 따르고, 본문에 여기 적힌 타입 정의(프로퍼티
표, PK, 인터페이스, 허용 출력 링크)를 옮긴다. 개념 노트가 스키마이고 같은 폴더의 나머지
md 가 인스턴스다.

인스턴스 frontmatter 는 `type: <ObjectType>` 을 그대로 쓴다. 이 8개 값은 프리셋 스킴
확장이 허용 노트 타입으로 등재하며 lint 상 document 로 취급된다([[team-ops-schema]]).

| 타입 | 폴더 | 개념 id | PK | 구현 인터페이스 |
|---|---|---|---|---|
| Team | `objects/teams/` | team | slug | HasIdentity, Temporal |
| Person | `objects/people/` | person | name | HasIdentity, Membered |
| Initiative | `objects/initiatives/` | initiative | slug | HasIdentity, Temporal, Owned |
| Decision | `objects/decisions/` | decision | slug | HasIdentity, Temporal |
| Practice | `objects/practices/` | practice | slug | HasIdentity, Owned |
| System | `objects/systems/` | system | slug | HasIdentity, Owned |
| Incident | `objects/incidents/` | incident | slug | HasIdentity, Temporal, Owned |
| Metric | `objects/metrics/` | metric | slug | HasIdentity, Owned |

PK 는 파일명이다. WS 안에서 유일해야 하고 한글도 된다. Person 만 `name` PK 다. 사람은
이름으로 부르고 이름이 안 바뀐다.

## 허용 출력 링크를 읽는 법

각 타입 절 끝의 "허용 출력 링크" 는 그 타입의 인스턴스가 **직접 걸 수 있는** 술어다.
정본 방향이 반대편에 있는 술어는 "비정본" 으로 따로 표시했다. 비정본 술어는 어휘에는
있으나 그 노트에 적는 것이 기본이 아니고, 반대편 노트에 이미 적혀 있으면 여기 또 적으면
규칙 11 위반이다([[team-ops-schema]]).

**정본 방향이 쌍마다 다르다는 점에 주의한다.** 소속은 사람 쪽(`memberOf`)이고 참여는
일 쪽(`hasParticipant`)이다. 기준은 갱신이 덜 일어나는 쪽이다.

[[team-ops-apply]] Step 2 가 이 목록을 대상 워크스페이스의 개념 노트 본문으로 옮긴다.
**옮길 때 비정본 줄을 그대로 가져가되 표시를 지우지 않는다.**

## Team

루트 객체. 이 워크스페이스가 담는 팀이다. 하위 스쿼드가 있으면 그것도 이 타입이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `name` | string | O | 팀명 |
| `mission` | text | O | 이 팀이 존재하는 이유 한 문단 |
| `formedAt` | date |  | 결성일 |
| `disbandedAt` | date |  | 해체일 (비움 = 활동 중) |
| `parentTeam` | -> Team |  | 상위 조직 |
| `chargeOf` | text |  | 책임 범위. 무엇까지가 우리 일인가 |
| `notChargeOf` | text |  | 책임 밖. 자주 오해받는 경계 |

허용 출력 링크: partOf -> Team.
비정본: hasMember -> Person (정본은 Person 쪽 memberOf), owns -> System/Metric,
runs -> Practice, pursues -> Initiative (셋 다 정본은 각 객체 쪽 ownedBy)

`notChargeOf` 가 이 타입에서 가장 값이 크다. 팀 경계는 하는 일 목록으로는 안 서고
**안 하는 일**로 선다. 인접 팀과 매번 다투는 지점을 여기 적어두면 그 다툼이 한 번으로
끝난다.

루트 Team 인스턴스에 `tags: [self, root]` 를 단다.

## Person

구성원과 외부 협력자. **사람 자체가 지식의 저장소가 되지 않게 하는 것**이 이 타입의
설계 목표다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 이름 (PK) |
| `role` | string |  | 현재 역할 |
| `joinedAt` | date |  | 합류일 |
| `leftAt` | date |  | 이탈일 (비움 = 재직 중) |
| `kind` | enum |  | member / lead / external / alumni |
| `contact` | string |  | 연락 경로 |
| `focus` | string[] |  | 지금 주로 보는 영역 |

허용 출력 링크: memberOf -> Team, oncallFor -> System.
비정본: participatesIn -> Initiative (정본은 Initiative 쪽 hasParticipant),
decided -> Decision (정본은 Decision 쪽 decidedBy)

**`focus` 는 담당이 아니라 현재 관심이다.** 소유는 사람이 아니라 Team 이나 Unit 성격의
주체에 붙인다. System 의 `owner` 를 사람으로 걸어두면 그 사람이 떠날 때 소유가 사라진다.
`oncall` 은 예외인데, 그것은 **지금 이 순간의 당번**이라 시점성이 본질이다.
그 역방향인 `oncallFor` 는 사람 노트에서 훑을 때의 편의 링크다.

이탈자는 지우지 않는다. `leftAt` 을 적고 `kind: alumni` 로 바꾼다. 과거 Decision 의
참여자로 계속 등장해야 한다.

## Initiative

시작과 끝이 있는 일감 묶음. 프로젝트, 마이그레이션, 실험, 분기 목표.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 하는가 |
| `status` | enum | O | proposed / active / paused / done / abandoned |
| `startDate` | date |  | 시작 |
| `endDate` | date |  | 종료 (비움 = 진행 중) |
| `owner` | -> Team | O | 책임 팀 |
| `goal` | text |  | 무엇이 달라지면 성공인가 |
| `outcome` | text |  | 실제로 무엇이 달라졌나 |
| `tracker` | url |  | 지라나 리니어 링크 |

허용 출력 링크: ownedBy -> Team, hasParticipant -> Person,
guidedBy -> Decision, changes -> System, movesMetric -> Metric

`status: abandoned` 를 지우지 않는 것이 중요하다. **접은 시도가 가장 자주 다시 제안
된다.** `outcome` 에 왜 접었는지 적어두면 같은 논의를 두 번 하지 않는다.

`tracker` 로 티켓을 가리키고 티켓 내용을 복사하지 않는다. 여기 적을 것은 `goal` 과
`outcome` 이다.

## Decision

의사결정 기록. 이 프리셋의 중심 타입이다. ADR 과 같은 자리이되 코드베이스가 아니라
팀 운영 전반을 덮는다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 정했는가. 결론을 제목에 |
| `status` | enum | O | proposed / accepted / superseded / reverted |
| `decidedAt` | date | O | 결정 시점 |
| `scope` | enum |  | technical / process / people / product |
| `reversible` | enum |  | easy / hard / oneWay |
| `context` | text | O | 무엇이 문제였는가 |
| `options` | text |  | 검토한 대안들 |
| `rationale` | text | O | 왜 이것을 골랐는가 |
| `consequences` | text |  | 무엇을 감수하기로 했는가 |

허용 출력 링크: decidedBy -> Person, supersedes -> Decision,
affects -> System/Practice/Metric.
비정본: supersededBy -> Decision (새 결정 쪽 supersedes 가 정본. 옛 결정은 status 만
바꾼다), arisesFrom -> Incident (정본은 Incident 쪽 triggers)

**`title` 에 결론을 적는다.** "데이터베이스 선정" 이 아니라 "주 저장소로 포스트그레스를
쓴다" 다. 목록에서 제목만 훑어도 팀의 현재 상태가 읽혀야 한다.

**`consequences` 를 비우지 않는다.** 대가 없는 결정은 없다. 여기가 비어 있으면 대안을
제대로 안 봤거나 대가를 안 적은 것이고, 나중에 그 대가가 터질 때 아무도 예상하지 못한
일로 취급된다.

`reversible: oneWay` 인 결정은 별도 취급이다. 되돌릴 수 없는 것은 결정 전에 더 봐야
하고, 결정 후에는 그 사실을 크게 남겨야 한다.

뒤집힌 결정은 지우지 않는다. `status: superseded` 로 바꾸고 `supersededBy` 를 건다.
새 결정 쪽에 `supersedes` 를 적는 것이 정본이다([[team-ops-schema]]).

## Practice

팀이 반복하는 절차와 의식. 스탠드업, 회고, 릴리스 절차, 온콜 로테이션, 코드 리뷰 규칙,
런북.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 하는가 |
| `kind` | enum | O | ritual / procedure / runbook / convention / rotation |
| `cadence` | string |  | 주기. 절차형이면 촉발 조건 |
| `owner` | -> Team | O | 유지 책임 |
| `steps` | text |  | 실제 순서 |
| `whyItExists` | text |  | 이 관행이 생긴 이유 |
| `lastReviewedAt` | date |  | 마지막 점검 |

허용 출력 링크: ownedBy -> Team, authoredBy -> Person, appliesTo -> System,
guidedBy -> Decision

**`whyItExists` 가 이 타입의 값이다.** 이유 없는 관행은 아무도 못 바꾼다. 다들 "원래
그랬다" 고만 알고 있어서 손대기를 무서워하고, 그래서 쓸모없어진 뒤에도 계속 돈다.
대개 과거의 Incident 나 Decision 이 원인이니 링크로 건다.

`kind: runbook` 은 장애 대응 절차다. Incident 에서 자주 파생되고 System 에 붙는다.

## System

팀이 소유하거나 운영하는 것. 서비스, 저장소, 파이프라인, 인프라, 외부 의존.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `name` | string | O | 시스템명 |
| `kind` | enum | O | service / datastore / pipeline / infra / dependency / tool |
| `tier` | enum |  | critical / important / supporting |
| `owner` | -> Team | O | 소유 팀 |
| `repo` | url |  | 저장소 |
| `runbook` | -> Practice |  | 장애 대응 절차 |
| `dashboards` | url[] |  | 관측 지점 |
| `purpose` | text |  | 무엇을 하는가 |

허용 출력 링크: ownedBy -> Team, dependsOn -> System, oncall -> Person.
비정본: observedBy -> Metric (정본은 Metric 쪽 observes)

`dependsOn` 이 이 워크스페이스에서 가장 자주 조회된다. 장애가 났을 때 "여기가 죽으면
뭐가 같이 죽나" 를 한 번의 읽기로 답해야 한다. **의존은 소비하는 쪽에 적는다.**

`kind: dependency` 는 팀이 소유하지 않지만 의존하는 외부다. 소유하지 않아도 노트가
필요하다. 그것이 죽으면 우리가 죽기 때문이다. 이 경우 `owner` 는 외부임을 표시하는
Team 인스턴스를 만들지 말고 `purpose` 에 공급자를 적는다.

## Incident

장애와 사고. 그리고 그 회고.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇이 일어났는가 |
| `severity` | enum | O | sev1 / sev2 / sev3 / nearMiss |
| `startedAt` | datetime | O | 시작 |
| `detectedAt` | datetime |  | 인지 |
| `resolvedAt` | datetime |  | 복구 (비움 = 진행 중) |
| `owner` | -> Team | O | 대응 주체 |
| `impact` | text |  | 누가 무엇을 못 했는가 |
| `rootCause` | text |  | 근본 원인 |
| `timeline` | text |  | 시각별 경과 |

허용 출력 링크: affects -> System, ownedBy -> Team, involvedPerson -> Person,
triggers -> Decision/Practice, similarTo -> Incident

`detectedAt` 과 `startedAt` 의 간격이 관측 품질 지표다. 두 값을 따로 두는 이유가 그것
이다. 하나로 합치면 "얼마나 늦게 알았나" 가 사라진다.

`severity: nearMiss` 를 버리지 않는다. 터지지 않은 것이 가장 싼 학습 재료다.

**회고에서 나온 것은 Incident 본문에 묻지 말고 객체로 꺼낸다.** 절차가 바뀌면 Practice,
방침이 바뀌면 Decision, 일감이 생기면 Initiative 다. `triggers` 로 건다. 회고 문서
안에만 적힌 액션 아이템은 실행되지 않는다.

## Metric

팀이 보는 숫자. 무엇으로 잘하고 있다고 판단하는가.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `name` | string | O | 지표명 |
| `kind` | enum | O | health / delivery / quality / business |
| `definition` | text | O | 정확히 어떻게 계산하는가 |
| `owner` | -> Team | O | 책임 팀 |
| `target` | string |  | 목표값 |
| `source` | string |  | 어디서 나오는 숫자인가 |
| `cadence` | string |  | 보는 주기 |

허용 출력 링크: ownedBy -> Team, observes -> System.
비정본: movedBy -> Initiative (정본은 Initiative 쪽 movesMetric)

**`definition` 에 계산식을 적고 현재 값을 적지 않는다.** 값은 대시보드에 있고 여기 적는
순간 스테일해진다. 이 노트가 답해야 하는 것은 "그 숫자가 정확히 무엇을 세는가" 다.
같은 이름의 지표를 두 사람이 다르게 계산하는 것이 팀에서 가장 흔한 숫자 사고다.

## 8종에 없는 것이 나오면 타입을 만든다

핵심 8종은 출발점이다. 울타리로 읽으면 안 된다. 어떤 대상이 8종 중 어디에도 정확히 맞지 않으면
가장 가까운 타입에 밀어넣지 말고 **새 타입 폴더를 만든다**. 판단 순서는 프로토콜과
같다. 정확히 맞는 기존 타입 -> 기존 타입의 특수화 -> 새 타입 폴더 -> 폴더를 가질 만큼
인스턴스가 없으면 추상 개념.

억지 분류의 신호: "Practice 는 아니지만 관행 폴더에", "Decision 으로 치자",
"kind 를 하나 늘려서".

### 예시: 인접 팀과의 인터페이스를 어디 둘까

인접 팀과 합의한 API 계약과 지원 범위를 넣으려 한다. 8종을 훑으면 어디에도 맞지 않는다.

- Team: 아니다. 상대 팀 노트는 따로 있고 이것은 둘 사이의 합의다
- Decision: 아니다. 한쪽이 정한 것이 아니라 양쪽이 합의한 것이라 뒤집는 절차가 다르다
- Practice: 아니다. 우리가 반복하는 절차가 아니라 상대와의 경계다
- System: 아니다. API 는 System 이지만 계약은 그 위의 약속이다

그러면 새 타입을 만든다. `Contract`, 폴더 `objects/contracts/`, 개념 id `contract`,
broader `team-knowledge`.

```yaml
# objects/contracts/contract.md 의 타입 정의 (개념 노트 본문)
type: Contract
plural: Contracts
primaryKey: slug
implements: [HasIdentity, Temporal, Owned]
```

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇에 대한 합의인가 |
| `parties` | -> Team[] | O | 합의 당사자 |
| `agreedAt` | date | O | 합의 시점 |
| `commitments` | text | O | 양쪽이 각각 무엇을 보장하는가 |
| `escalation` | text |  | 깨졌을 때 어디로 |

허용 출력 링크: `guidedBy` -> Decision, `ownedBy` -> Team, 그리고 **새로 등재해야 하는
술어 둘** `betweenTeams` -> Team, `coversSystem` -> System.

뒤의 둘은 [[team-ops-schema]] 술어 표에 아직 없다. 이 예시를 그대로 쓰려면 타입 폴더를
만들기 전에 표에 두 행을 먼저 추가해야 한다(스키마 우선 원칙). 등재하지 않고 쓰면
규칙 10 위반이다.

Decision 과 같은 자리에 서고 대부분의 술어를 공유한다. 다른 것은 당사자가 둘이라는 점
하나다. 그 한 가지가 개정 절차를 통째로 다르게 만들어서 타입이 갈린다. 우리 결정은
우리가 뒤집지만 합의는 상대와 다시 앉아야 한다.

## 타입 추가: 프리셋 고유 델타

절차의 정본은 프로토콜이다. `_context-protocol/_ontology.md` 의 "둘 곳이 없으면 만든다" 와 "어휘를
늘릴 때" 를 따른다. 여기 다시 적지 않는다.

이 프리셋에서만 추가로 지켜야 하는 것:

1. 인스턴스 폴더는 `objects/<복수형>/` 아래에 두고 개념 노트는 그 안에 단수형 개념
   id 로 둔다. `broader` 는 `[[team-knowledge]]`.
2. 개념 노트 본문에 프로퍼티 표, PK, `implements`, 허용 출력 링크를 적는다.
3. 새 술어는 [[team-ops-schema]] 의 술어 표에 행을 추가한다.
4. **새 타입이 사람에게 귀속되지 않는지 확인한다.** 어떤 타입이 특정 개인이 있어야만
   의미가 서면 그것은 이 프리셋의 전제를 깨는 타입이다. 소유는 Team 에 붙는다.
5. `templates/<타입>.md.tpl` 을 추가하고 [[object-template]] 의 수록 목록을 갱신한다.
