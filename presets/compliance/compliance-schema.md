---
type: document
title: compliance 스킴 확장 (술어·인터페이스·값 타입·공유 프로퍼티)
updated: 2026-09-10
---

# 스킴 확장

대상 워크스페이스의 `_context-protocol/_schema/concept-scheme.md` 에 병합할 확장이다. 코어 스킴의
허용 노트 타입과 술어에 아래를 **추가**하고, 코어 규칙은 그대로 둔다.

술어와 값 타입은 폴더를 소유할 수 없는 스키마라 한 파일에 모았다. 헤드리스 에이전트
에게는 한 번 읽어 어휘 전체를 확보하는 편이 낫다. [[personal-rag-schema]] 와 같은
구성이다.

## 허용 노트 타입 추가

코어의 concept / document / schema / project-descriptor / readme / view / proposal 에
객체 타입 8개를 추가한다.

```
Statute, Regulation, Obligation, Control, Evidence, Audit, Finding, Unit
```

이 8개는 lint 상 **document 와 동일하게** 취급한다. 소속이 결정돼야 하고(개념 폴더 안에
있거나 `subject` 를 갖거나) `broader` 는 갖지 않는다(개념이 아니다).

## 술어 어휘

프로퍼티가 아니라 관계다. frontmatter `links:` 맵 또는 본문 섹션의 위키링크로 쓴다.
`broader` / `related` / `subject` 는 코어 소관이니 객체 관계에 재사용하지 않는다.

### 사슬 (이 프리셋의 척추)

| 술어 | 방향 | 기수 | 의미 |
|---|---|---|---|
| basedOn | Regulation -> Statute | n:n | 이 규정의 외부 근거 |
| derives | Regulation -> Obligation | 1:n | 이 규정에서 도출된 의무 |
| requiredBy | Obligation -> Statute/Regulation | n:n | 이 의무를 요구하는 근거 |
| implementedBy | Obligation -> Control | 1:n | 이 의무를 이행하는 통제 |
| implements | Control -> Obligation | n:n | 역방향 |
| produces | Control -> Evidence | 1:n | 이 통제가 남기는 증거 |
| evidenceFor | Evidence -> Obligation | n:n | 이 증거가 충족하는 의무 |
| producedBy | Evidence -> Control | n:1 | 역방향 |

`derives` 와 `requiredBy` 는 같은 사실의 양 방향이다. **정본은 `requiredBy` 쪽이다.**
의무 노트가 자기 근거를 들고 있어야 "이걸 왜 해야 하나" 에 한 번의 읽기로 답한다.
규정 노트에 `derives` 를 적는 것은 규정에서 내려갈 때만이고, 둘 다 적지 않는다(규칙 11).

`implementedBy` 와 `implements` 도 같은 사실의 양 방향이다. **정본은 `implements`
쪽이다.** 통제가 여러 의무를 동시에 충족하는 경우가 흔해서 통제 쪽에 모아두는 편이
갱신이 적다.

`produces` 와 `producedBy` 도 같은 사실의 양 방향이다. **정본은 `evidenceFor` 와
`producedBy` 쪽, 즉 증거 노트 쪽이다.** 증거는 계속 쌓이므로 통제 노트에 증거 목록을
두면 그 노트가 무한히 길어지고 매 실행마다 두 곳을 고치게 된다. 통제 쪽의 `produces`
는 어떤 종류의 증거가 나오는지를 한 번 적어두는 자리다. 인스턴스 목록을 여기 쌓지 않는다.

### 조직과 책임

| 술어 | 방향 | 의미 |
|---|---|---|
| ownedBy | Regulation/Obligation/Control/Finding -> Unit | 책임 주체 |
| accountableFor | Unit -> 다용도 | 역방향. Unit 노트에서 자기 책임 범위를 훑을 때 |
| partOf | Unit -> Unit | 조직 계층 |
| performedBy | Audit -> Unit | 점검 수행 주체 |
| collectedBy | Evidence -> Unit | 증거 수집 주체 |

`ownedBy` 가 정본이다. `accountableFor` 는 Unit 노트가 커질 때만 쓴다. 둘 다 적지
않는다.

**모든 책임 술어의 range 는 Unit 이다.** 사람 이름을 넣으면 규칙 13 위반이다.

### 점검과 시정

| 술어 | 방향 | 의미 |
|---|---|---|
| scopeCovers | Audit -> Obligation/Control/Regulation | 점검 범위 |
| raises | Audit -> Finding | 지적 제기 |
| raisedBy | Finding -> Audit | 역방향 |
| affects | Finding -> Obligation/Control/Regulation | 무엇이 결함인가 |
| resolvedBy | Finding -> Evidence | 시정을 증명하는 증거 |
| citedIn | Evidence -> Audit/Finding | 이 증거가 인용된 곳 |

`raises` 와 `raisedBy` 중 **정본은 `raisedBy` 쪽이다.** 지적사항이 자기 출처를 들고
있어야 독립 라이프사이클을 돌면서도 근거를 잃지 않는다.

### 시간과 개정

| 술어 | 방향 | 의미 |
|---|---|---|
| supersedes | Statute/Regulation -> 동일 타입 | 이 판이 대체한 이전 판 |
| amendedBy | Statute -> Statute | 개정 법령 |
| dependsOn | Control -> Control | 선행 통제 |
| references | 다용도 | 참조 |

개정은 **덮어쓰지 않고 새 인스턴스 + `supersedes`** 다. 이전 판을 지우면 그 판이
유효하던 기간의 증거가 근거를 잃는다.

### 보조 술어

의미가 자명해 별도 정의를 두지 않고 어휘에만 등재한다.

`counterparty` (계약 상대), `authority` (소관 기관), `system` (사용 시스템),
`relatedObjects` / `relatedViews` (다용도 연결).

## 인터페이스 (추상 타입)

여러 타입이 공통으로 갖는 구조. 폴더를 만들지 않고 이 표로만 존재한다. 각 객체 타입
개념 노트의 `implements:` 에 이름을 적는다.

### HasIdentity

구현: 8종 전부. [[personal-rag-schema]] 의 같은 이름 인터페이스와 요구가 같다.
`name` 또는 `slug`(필수), `aliases`, `tags`, `description`.

`identifiers` 와 `webPresence` 는 이 프리셋에서 쓰지 않는다. 컴플라이언스 객체는 사람이
아니라 문서와 절차라 계정 레지스트리가 필요 없다.

### Temporal

구현: Statute, Regulation, Evidence, Audit, Finding. 유효 기간과 만료 판정의 기준이다.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| 시작 필드 | O | effectiveFrom / coversFrom / startDate / raisedAt |
| 종료 필드 |  | effectiveTo / coversTo / endDate / closedAt |

종료가 비었을 때의 의미가 타입마다 다르다. Statute·Regulation 은 유효, Audit 은 진행
중, Finding 은 열림이다. **Evidence 만 예외로 `coversTo` 가 필수다.** 끝이 없는 증거는
증거가 아니다.

### Recurring

구현: Obligation, Control. 주기가 있는 것.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `cadence` | O | Cadence 값 타입 |
| `dueRule` 또는 `lastRunAt` |  | 다음 기한 산정에 쓴다 |

### Owned

구현: Regulation, Obligation, Control, Finding. 책임 주체가 반드시 있는 것.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `owner` 또는 `ownedBy` 링크 | O | Unit 참조 |

Statute 는 Owned 가 아니다. 외부 규범에는 사내 책임 주체가 없다. 그것을 지킬 책임은
Statute 가 아니라 거기서 도출된 Obligation 에 붙는다.

## 값 타입

### Cadence

주기. Obligation 과 Control 이 공유한다.

```yaml
cadence:
  kind: quarterly    # oneOff / daily / weekly / monthly / quarterly / semiAnnual / annual / eventDriven
  anchor: 분기 종료   # 기준점. eventDriven 이면 촉발 사건
  graceDays: 30      # 기준점 이후 허용 기간
```

`eventDriven` 은 주기가 아니라 사건이 방아쇠인 경우다. 침해 사고 신고처럼 언제 일어날지
모르지만 일어나면 기한이 걸린다. `anchor` 에 촉발 사건을 적는다.

### ComplianceStatus

의무 이행 상태 enum.

- `met` 충족 - 유효한 증거가 있다
- `partial` 부분 충족 - 통제는 있으나 증거가 일부만 있거나 기간이 안 맞는다
- `unmet` 미충족 - 통제가 없거나 증거가 없다
- `notApplicable` 비해당 - 조직에 적용되지 않는다. **이유를 반드시 함께 적는다**

규칙: `met` 은 손으로 적는 값이 아니라 증거에서 도출된다. `notApplicable` 은 가장 남용
되기 쉬운 값이라 근거 없는 비해당을 lint 가 잡는다(규칙 18).

## 공유 프로퍼티

| 이름 | 타입 | 사용 | 설명 |
|---|---|---|---|
| `tags` | string[] | 전체 | 자유 분류 |
| `description` | text | 전체 | 짧은 설명 |
| `updated` | date | 전체 | 마지막 갱신 (GUIDE §6 이 bump) |
| `sources` | url[] | 전체 | 출처와 근거 |
| `confidence` | enum | 전체 | low / medium / high |
| `location` | string | Regulation·Evidence | 정본 원본이 실제로 있는 위치 |
| `severity` | enum | Obligation·Finding | low / medium / high / critical (Finding 은 observation / minor / major / critical) |

### location 규칙

**이 프리셋에서 `location` 은 사실상 필수다.** Evidence 는 스키마상 필수이고,
Regulation 도 없으면 노트가 요약본으로 전락한다.

적는 방식은 셋 중 하나다.

1. URL - 사내 시스템 링크
2. 경로 - 공유 드라이브나 문서관리시스템의 경로. 폴더명만 있고 문서명이 없으면 안 된다
3. 오프라인 - 물리 보관이면 보관 장소와 접근 절차

접근 권한이 필요하면 그 사실을 함께 적는다. 에이전트가 열지 못하는 것을 열려고 반복
시도하는 것을 막는다.

## 무결성 규칙 추가

코어 lint 규칙 1~6 에 더한다. 점검 방법은 [[compliance-lint]].

7. 객체 인스턴스의 `type:` 은 허용 노트 타입에 등재된 값이어야 한다.
8. 객체 인스턴스는 필수 프로퍼티(PK, 각 타입의 O 표시)를 모두 갖는다.
9. `links:` 와 본문의 모든 위키링크는 실재하는 노트를 가리킨다.
10. 술어는 이 문서의 어휘에 있는 것만 쓴다. 새 술어는 표에 추가하고 나서 쓴다.
11. 정방향과 역방향 술어를 같은 사실에 대해 양쪽 노트에 동시에 적지 않는다. 정본 방향은
    아래 표가 정본이다.

| 쌍 | 정본 (여기 적는다) | 비정본 |
|---|---|---|
| 규정과 의무 | Obligation 의 `requiredBy` | Regulation 의 `derives` |
| 의무와 통제 | Control 의 `implements` | Obligation 의 `implementedBy` |
| 통제와 증거 | Evidence 의 `producedBy`, `evidenceFor` | Control 의 `produces` |
| 책임 | 각 객체의 `ownedBy` | Unit 의 `accountableFor` |
| 점검과 지적 | Finding 의 `raisedBy` | Audit 의 `raises` |

비정본 쪽은 사람이 그 노트를 읽을 때의 편의 링크이고 갱신 의무가 없다. 템플릿은 정본
슬롯만 제공한다.
12. 객체 인스턴스는 `broader` 를 갖지 않는다.

여기까지는 [[personal-rag-schema]] 와 같다. 아래 여섯이 이 프리셋 고유다.

13. **책임 술어의 대상은 Unit 이다.** `ownedBy`, `performedBy`, `collectedBy`,
    `accountableFor` 가 사람 이름 문자열을 가리키면 위반이다.
14. **Obligation 은 근거를 갖는다.** `requiredBy` 가 없는 의무는 어디서 왔는지 알 수
    없다.
15. **`status: met` 은 유효한 Evidence 를 갖는다.** 증거가 없거나 기간이 안 맞으면
    `partial` 이나 `unmet` 이다.
16. **Evidence 의 기간이 Obligation 의 주기를 덮는다.** 분기 의무에 작년 증거가 붙어
    있으면 위반이다.
17. **열린 Finding 의 기한이 지나지 않았다.** `closedAt` 이 비고 `dueAt` 이 과거면
    위반이다. 이것은 데이터 오류가 아니라 **실제 컴플라이언스 결함**이라 lint 가 잡는
    것이 목적에 맞다.
18. **`notApplicable` 은 이유를 갖는다.** `summary` 나 본문에 비해당 근거가 없으면
    위반이다.

13~18 은 구조 검사와 실질 검사가 섞여 있다. 의도한 것이다. 이 워크스페이스가 답해야
하는 질문이 "구조가 온전한가" 가 아니라 "우리가 지키고 있나" 이기 때문이다.
