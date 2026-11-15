---
type: document
title: compliance 객체 타입 8종
updated: 2026-09-10
---

# 객체 타입 8종

각 타입은 대상 워크스페이스에서 `objects/<folder>/<concept-id>.md` 개념 노트가 된다.
그 노트의 frontmatter 는 개념 노트 규약(type/scheme/pref_label/broader/definition)을
따르고, 본문에 여기 적힌 타입 정의(프로퍼티 표, PK, 인터페이스, 허용 출력 링크)를
옮긴다. 개념 노트 자체는 스키마이고, 같은 폴더의 나머지 md 가 인스턴스다.

인스턴스 frontmatter 는 `type: <ObjectType>` 을 그대로 쓴다. 이 8개 값은 프리셋
스킴 확장이 허용 노트 타입으로 등재하며 lint 상 document 로 취급된다
([[compliance-schema]]).

| 타입 | 폴더 | 개념 id | PK | 구현 인터페이스 |
|---|---|---|---|---|
| Statute | `objects/statutes/` | statute | slug | HasIdentity, Temporal |
| Regulation | `objects/regulations/` | regulation | slug | HasIdentity, Temporal, Owned |
| Obligation | `objects/obligations/` | obligation | slug | HasIdentity, Recurring, Owned |
| Control | `objects/controls/` | control | slug | HasIdentity, Recurring, Owned |
| Evidence | `objects/evidence/` | evidence | slug | HasIdentity, Temporal |
| Audit | `objects/audits/` | audit | slug | HasIdentity, Temporal |
| Finding | `objects/findings/` | finding | slug | HasIdentity, Temporal, Owned |
| Unit | `objects/units/` | unit | name | HasIdentity |

PK 는 파일명이다. WS 안에서 유일해야 하고 한글도 된다. Unit 만 `name` PK 이고 나머지는
`slug` 다. 규정과 의무는 이름이 길고 개정될 때 바뀌므로 안정적인 식별자가 필요하다.

`evidence` 폴더만 단수형이다. 영어에서 셀 수 없는 명사라 복수형이 없다. 개념 id 와
타입명 규약(단수)은 그대로다.

## 허용 출력 링크를 읽는 법

각 타입 절 끝의 "허용 출력 링크" 는 그 타입의 인스턴스가 **직접 걸 수 있는** 술어다.
정본 방향이 반대편에 있는 술어는 "비정본" 으로 따로 표시했다. 비정본 술어는 어휘에는
있으나 그 노트에 적는 것이 기본이 아니고, 반대편 노트에 이미 적혀 있으면 여기 또 적으면
규칙 11 위반이다([[compliance-schema]]).

[[compliance-apply]] Step 2 가 이 목록을 대상 워크스페이스의 개념 노트 본문으로 옮긴다.
**옮길 때 비정본 줄을 그대로 가져가되 표시를 지우지 않는다.** 표시를 지우면 설치된
워크스페이스가 규칙 11 위반을 허용으로 광고하게 된다.

## Statute

외부 규범. 법률, 시행령, 시행규칙, 고시, 조례, 그리고 감독기관 가이드라인. **조직이
바꿀 수 없는 것**이 이 타입의 판별 기준이다.

한 인스턴스의 단위는 법령 전체가 아니라 **조직에 적용되는 조문 묶음**이다. 개인정보
보호법 전문을 한 노트에 담으면 어느 조문이 우리에게 걸리는지 알 수 없다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 법령명과 조문 범위 |
| `kind` | enum | O | act / decree / rule / notice / ordinance / guideline |
| `articles` | string[] |  | 적용 조문 번호 |
| `authority` | string |  | 소관 부처나 감독기관 |
| `effectiveFrom` | date | O | 시행일 |
| `effectiveTo` | date |  | 폐지일 (비움 = 유효) |
| `amendedAt` | date[] |  | 개정 이력 |
| `sourceUrl` | url |  | 원문 링크 |
| `summary` | text |  | 이 조문이 조직에 요구하는 것 |

허용 출력 링크: supersedes -> Statute, amendedBy -> Statute

원문을 본문에 복사하지 않는다. `sourceUrl` 로 가리키고 `summary` 에 조직 관점의 요구
사항만 적는다. 원문 전문이 필요하면 `datasources/` 에 인덱스를 둔다.

## Regulation

사내 규범. 규정, 지침, 매뉴얼, 표준, 절차서. **조직이 만들었고 조직이 고칠 수 있는
것**이 판별 기준이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 규정명 |
| `kind` | enum | O | policy / standard / procedure / manual / guideline |
| `version` | string | O | 판 번호 |
| `effectiveFrom` | date | O | 시행일 |
| `effectiveTo` | date |  | 폐지일 (비움 = 유효) |
| `reviewCycle` | Cadence |  | 정기 재검토 주기 |
| `approvedBy` | -> Unit |  | 제정 승인 주체 |
| `owner` | -> Unit | O | 유지 책임 조직 단위 |
| `location` | string |  | 정본 문서가 실제로 있는 위치 |
| `summary` | text |  | 무엇을 규율하는가 |

허용 출력 링크: basedOn -> Statute, ownedBy -> Unit, supersedes -> Regulation.
비정본: derives -> Obligation (정본은 Obligation 쪽 requiredBy)

`location` 이 이 타입에서 가장 자주 빠지고 가장 아프다. 규정 정본이 사내 그룹웨어나
문서관리시스템에 있는데 그 경로를 안 적으면 노트가 요약본으로 전락한다.

## Obligation

이행 의무. 법령이나 규정이 조직에 요구하는 행위와 그 주기다. **조직이 없앨 수 없는
것**이 Control 과의 판별 기준이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 해야 하는가 |
| `cadence` | Cadence | O | 주기. 일회성이면 kind=oneOff |
| `dueRule` | string |  | 기한 산정 규칙. 예: 분기 종료 후 30일 이내 |
| `owner` | -> Unit | O | 책임 조직 단위 |
| `severity` | enum |  | low / medium / high / critical |
| `penalty` | text |  | 미이행 시 제재 |
| `status` | ComplianceStatus | O | met / partial / unmet / notApplicable |
| `summary` | text |  | 요구 내용 |

허용 출력 링크: requiredBy -> Statute/Regulation, ownedBy -> Unit.
비정본: implementedBy -> Control (정본은 Control 쪽 implements)

`status` 는 손으로 적는 값이 아니라 **증거로부터 도출되는 값**이다. 유효한 Evidence 가
붙어 있지 않은데 `met` 이면 lint 가 잡는다([[compliance-lint]] 규칙 15).

## Control

통제 장치. 의무를 실제로 이행하는 절차나 시스템이다. **다른 방법으로 갈아 끼울 수 있는
것**이 Obligation 과의 판별 기준이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 어떻게 하는가 |
| `kind` | enum | O | preventive / detective / corrective |
| `automation` | enum | O | manual / semiAuto / automated |
| `cadence` | Cadence | O | 실행 주기 |
| `owner` | -> Unit | O | 운영 주체 |
| `system` | string |  | 사용하는 시스템이나 도구 |
| `procedure` | text |  | 실행 절차 |
| `lastRunAt` | date |  | 마지막 실행 |

허용 출력 링크: implements -> Obligation, ownedBy -> Unit, produces -> Evidence,
dependsOn -> Control

`automation: manual` 인 Control 이 많을수록 증거가 잘 끊긴다. 감사 준비의 첫 작업은
대개 수동 통제를 세는 것이다.

## Evidence

이행 증거. 통제가 실제로 돌았다는 기록을 **가리키는** 노트다. 증거 원본이 아니다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 증명하는가 |
| `kind` | enum | O | log / approval / report / screenshot / attestation / config |
| `coversFrom` | date | O | 증거가 덮는 기간의 시작 |
| `coversTo` | date | O | 끝 |
| `location` | string | O | 원본이 실제로 있는 위치 |
| `collectedBy` | -> Unit |  | 수집 주체 |
| `collectedAt` | date |  | 수집 시점 |
| `verifiedAt` | date |  | 확인 시점 |

허용 출력 링크: evidenceFor -> Obligation, producedBy -> Control,
citedIn -> Audit/Finding

`coversFrom` 과 `coversTo` 가 필수인 이유는 증거의 유효 기간이 이 타입의 존재 이유이기
때문이다. 분기 의무에 작년 증거가 붙어 있으면 붙어 있으나 마나다. lint 규칙 16 이 이
불일치를 센다.

원본을 워크스페이스로 복사하지 않는다. `location` 에 경로나 URL 을 적고, 접근 권한이
필요하면 그 사실도 함께 적는다.

## Audit

점검. 내부 감사, 외부 감사, 인증 심사, 규제기관 검사, 자체 점검.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 점검명 |
| `kind` | enum | O | internal / external / certification / regulatory / selfCheck |
| `auditor` | string |  | 외부 수행 주체의 이름. 사내 주체는 이 칸을 비우고 performedBy 로 건다 |
| `startDate` | date | O | 시작 |
| `endDate` | date |  | 종료 (비움 = 진행 중) |
| `scope` | text |  | 점검 범위 |
| `result` | enum |  | pass / passWithFindings / fail / inProgress |

허용 출력 링크: scopeCovers -> Obligation/Control/Regulation, performedBy -> Unit.
비정본: raises -> Finding (정본은 Finding 쪽 raisedBy)

`scope` 를 산문으로만 적으면 다음 감사 때 범위를 다시 짜야 한다. `scopeCovers` 링크로
객체를 직접 가리키면 범위가 재사용된다.

## Finding

지적사항. 감사에서 나온 결함과 그 시정 추적이다. 감사와 별도 라이프사이클을 갖기 때문에
Audit 의 부속이 아니라 독립 타입이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇이 문제인가 |
| `severity` | enum | O | observation / minor / major / critical |
| `raisedAt` | date | O | 제기 시점 |
| `dueAt` | date |  | 시정 기한 |
| `closedAt` | date |  | 종결 시점 (비움 = 열림) |
| `owner` | -> Unit | O | 시정 책임 |
| `remediation` | text |  | 시정 계획과 진행 |
| `rootCause` | text |  | 근본 원인 |

허용 출력 링크: raisedBy -> Audit, affects -> Obligation/Control/Regulation,
ownedBy -> Unit, resolvedBy -> Evidence

`closedAt` 이 비어 있고 `dueAt` 이 지난 Finding 이 이 워크스페이스의 가장 급한 질의
대상이다. lint 규칙 17 이 센다.

## Unit

조직 단위. 부서, 팀, 위원회, 직책. 사슬의 각 마디에 책임을 붙이는 자리다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 단위명 (PK) |
| `kind` | enum | O | department / team / committee / role / external |
| `currentHolder` | string |  | 현재 담당자 이름과 직책 |
| `holderSince` | date |  | 담당 시작 |
| `contact` | string |  | 연락 경로 |
| `mandate` | text |  | 이 단위가 지는 책임 범위 |

허용 출력 링크: partOf -> Unit.
비정본: accountableFor -> Obligation/Control/Regulation/Finding (정본은 각 객체 쪽 ownedBy)

**사람 이름은 `currentHolder` 프로퍼티에만 산다.** 사슬의 링크는 절대 사람을 가리키지
않는다. 담당자가 바뀌면 이 노트 한 줄과 `holderSince` 만 고치고 로그에 남긴다. 이전
담당자를 지우지 말고 본문에 이력으로 남기는 것을 권장한다.

상위 단위는 프로퍼티가 아니라 `partOf` 링크 하나로만 적는다. 프로퍼티와 링크에
같은 사실을 두 번 적으면 갱신이 갈라진다.

`kind: external` 은 외부 위탁처와 감사인이다. 조직 단위는 아니지만 책임을 지므로 같은
타입에 둔다. 이것을 별도 타입으로 쪼개면 `accountableFor` 링크의 range 가 둘로 갈라져
질의가 복잡해진다.

## 8종에 없는 것이 나오면 타입을 만든다

핵심 8종은 출발점이다. 울타리로 읽으면 안 된다. 어떤 대상이 8종 중 어디에도 정확히 맞지 않으면,
가장 가까운 타입에 밀어넣지 말고 **새 타입 폴더를 만든다**. 프로토콜의 구조 생성 원칙
(`_context-protocol/_ontology.md` "둘 곳이 없으면 만든다")이 프리셋 안에서 이렇게 구체화된다.

판단 순서는 프로토콜과 같다. 정확히 맞는 기존 타입 -> 기존 타입의 특수화 -> 새 타입
폴더 -> 폴더를 가질 만큼 인스턴스가 없으면 추상 개념.

억지 분류의 신호: "Regulation 은 아니지만 규정 폴더에", "Evidence 로 치자",
"kind 를 하나 늘려서".

### 예시: 위탁 계약을 어디 둘까

개인정보 처리 위탁 계약서를 넣으려 한다. 8종을 훑으면 어디에도 맞지 않는다.

- Statute: 아니다. 외부 규범이 아니라 당사자 합의다
- Regulation: 아니다. 조직이 일방적으로 고칠 수 없다. 상대가 있다
- Obligation: 아니다. 계약에서 의무가 여러 개 도출된다. 계약 자체는 그 그릇이다
- Evidence: 아니다. 계약 체결이 이행 증거가 되는 경우도 있으나 계약 자체는 근거 문서다

그러면 새 타입을 만든다. `Agreement`, 폴더 `objects/agreements/`, 개념 id `agreement`,
broader `compliance-chain`.

```yaml
# objects/agreements/agreement.md 의 타입 정의 (개념 노트 본문)
type: Agreement
plural: Agreements
primaryKey: slug
implements: [HasIdentity, Temporal, Owned]
```

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 계약명 |
| `counterparty` | -> Unit | O | 상대방 (kind=external) |
| `signedAt` | date | O | 체결일 |
| `expiresAt` | date |  | 만료일 |
| `location` | string | O | 계약서 원본 위치 |

허용 출력 링크: `derives` -> Obligation, `basedOn` -> Statute,
`ownedBy` -> Unit, `counterparty` -> Unit.

Regulation 과 같은 자리에 서고 같은 술어를 쓴다. 다른 것은 상대방이 있다는 점 하나다.
그 한 가지가 개정 절차와 만료 관리를 통째로 다르게 만들어서 타입이 갈린다.

## 타입 추가: 프리셋 고유 델타

절차의 정본은 프로토콜이다. `_context-protocol/_ontology.md` 의 "둘 곳이 없으면 만든다" 와 "어휘를
늘릴 때" 를 따른다. 여기 다시 적지 않는다.

이 프리셋에서만 추가로 지켜야 하는 것:

1. 인스턴스 폴더는 `objects/<복수형>/` 아래에 두고 개념 노트는 그 안에 단수형 개념
   id 로 둔다. `broader` 는 `[[compliance-chain]]`.
2. 개념 노트 본문에 프로퍼티 표, PK, `implements`, 허용 출력 링크를 적는다.
3. 새 술어는 [[compliance-schema]] 의 술어 표에 행을 추가한다. 코어 concept-scheme
   에는 타입명 등재만 하고 술어 정의는 넣지 않는다.
4. **새 타입이 사슬의 어느 마디에 서는지 밝힌다.** 사슬 밖에 떠 있는 타입은 질의에
   걸리지 않는다. 위 Agreement 예시가 "Regulation 과 같은 자리" 라고 밝힌 것이 그것이다.
5. `templates/<타입>.md.tpl` 을 추가하고 [[object-template]] 의 수록 목록을 갱신한다.
