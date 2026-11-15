---
type: document
title: team-ops 스킴 확장 (술어·인터페이스·값 타입·공유 프로퍼티)
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
Team, Person, Initiative, Decision, Practice, System, Incident, Metric
```

이 8개는 lint 상 **document 와 동일하게** 취급한다. 소속이 결정돼야 하고 `broader` 는
갖지 않는다.

`Person` 은 [[personal-rag-schema]] 에도 있는 이름이다. **두 프리셋을 한 워크스페이스에
같이 얹지 않는 것을 권장한다.** 충돌이 프로퍼티 표 하나가 아니라 여섯 겹이다.

| 충돌 지점 | personal-rag | team-ops |
|---|---|---|
| 주소 | `objects/people/person.md` | 같음. 한 파일이 두 타입 정의를 동시에 담아야 한다 |
| implements | HasIdentity, Temporal | HasIdentity, Membered. `memberOf` 가 필수라 가족·친구 인스턴스가 규칙 8 위반이 된다 |
| 프로퍼티 | birthDate, gender, nationality, currentLocation, bio, firstMet | role, joinedAt, leftAt, kind, contact, focus. 교집합이 `name` 하나다 |
| `tags` 의미 | 관계 분류(family/friend/colleague) | 자유 분류. 같은 축은 `kind` enum 에 있다 |
| 루트 마커 | 루트 Person 에 `tags: [self, root]` | 루트 Team 에 같은 마커. root 가 둘이 된다 |
| 템플릿 파일명 | `templates/person.md.tpl` | 같음. 적용 시 한쪽이 덮인다 |

굳이 병행해야 하면 **타입명만 바꾸는 것으로는 부족하다.** 폴더명, 개념 id, 템플릿
파일명을 함께 바꾸고 루트 마커를 하나로 정리해야 한다. 넷 중 하나라도 빠지면 같은
폴더에 두 종류가 섞여 규칙 10 판정이 불가능해진다.

프라이버시 축도 갈린다. personal-rag Person 은 생년월일과 거주지를 정식 프로퍼티로
두는데, 이 프리셋은 팀 전원이 읽는 워크스페이스를 전제해 [[team-ops-intake]] 가 그런
항목을 묻지 않는다. 두 표를 합치면 그 방어가 무력해진다.

## 술어 어휘

프로퍼티가 아니라 관계다. frontmatter `links:` 맵 또는 본문 섹션의 위키링크로 쓴다.
`broader` / `related` / `subject` 는 코어 소관이니 객체 관계에 재사용하지 않는다.

### 소속과 참여

| 술어 | 방향 | 기수 | 의미 |
|---|---|---|---|
| memberOf | Person -> Team | n:n | 소속 |
| hasMember | Team -> Person | 1:n | 역방향 |
| partOf | Team -> Team | n:1 | 조직 계층 |
| participatesIn | Person -> Initiative | n:n | 참여 |
| hasParticipant | Initiative -> Person | 1:n | 역방향 |
| involvedPerson | Incident -> Person | 1:n | 대응 참여 |

`memberOf` 와 `hasMember` 중 **정본은 `memberOf` 쪽이다.** 사람 노트가 자기 소속을 들고
있어야 이탈 처리가 한 곳에서 끝난다. 팀 노트에 명단을 박아두면 사람이 나갈 때 두 곳을
고쳐야 하고 대개 한 곳만 고친다.

`participatesIn` 과 `hasParticipant` 중 **정본은 `hasParticipant` 쪽이다.** 이니셔티브는
끝나면 닫히고 그 참여자 명단은 그 시점에 고정된다. 사람 노트에 참여 이력을 계속 쌓으면
노트가 무한히 길어진다.

두 쌍의 정본 방향이 서로 반대인 것은 의도한 것이다. **갱신이 덜 일어나는 쪽에 적는다**
가 기준이고, 소속은 사람 쪽이, 참여는 일 쪽이 덜 움직인다.

### 소유와 운영

| 술어 | 방향 | 의미 |
|---|---|---|
| ownedBy | Initiative/Practice/System/Incident/Metric -> Team | 소유 팀 |
| owns | Team -> System/Metric | 역방향. 팀 노트에서 훑을 때 |
| runs | Team -> Practice | 팀이 돌리는 관행 |
| pursues | Team -> Initiative | 팀이 미는 일 |
| oncall | System -> Person | 현재 당번 |
| oncallFor | Person -> System | 역방향 |
| authoredBy | Practice -> Person | 최초 작성자 |
| dependsOn | System -> System | 의존 |
| appliesTo | Practice -> System | 이 절차가 걸리는 대상 |
| observes | Metric -> System | 이 지표가 보는 대상 |
| observedBy | System -> Metric | 역방향 |

`ownedBy` 가 정본이다. `owns`, `runs`, `pursues` 는 Team 노트를 사람이 읽을 때의 편의
링크이고 갱신 의무가 없다.

**`ownedBy` 의 range 는 Team 이다.** 사람을 가리키면 규칙 13 위반이다. 예외는 `oncall`
하나이고 그것은 시점성이 본질이라 사람이 맞다.

`dependsOn` 은 **소비하는 쪽에 적는다.** A 가 B 를 쓰면 A 노트에 적는다. 제공하는 쪽에
소비자 목록을 두면 새 소비자가 생길 때마다 제공자 노트를 고쳐야 한다.

`observes` 와 `observedBy` 중 **정본은 `observes`, 즉 지표 쪽이다.** 시스템 하나에
지표가 여러 개 붙고 지표는 늘었다 줄었다 하는데, 시스템 노트가 그때마다 바뀌는 것은
낭비다.

`oncall` 과 `oncallFor` 중 **정본은 `oncall`, 즉 시스템 쪽이다.** 당번은 시스템에
붙는 속성이고 사람은 지나간다. 규칙 13 이 이 술어만 사람을 허용하는 이유도 같다.

### 결정의 인과

| 술어 | 방향 | 의미 |
|---|---|---|
| decidedBy | Decision -> Person | 결정 참여자 |
| decided | Person -> Decision | 역방향 |
| supersedes | Decision -> Decision | 이 결정이 대체한 것 |
| supersededBy | Decision -> Decision | 역방향 |
| affects | Decision/Incident -> System/Practice/Metric | 무엇이 바뀌는가. Incident 는 무엇이 망가졌는가 |
| guidedBy | Initiative/Practice -> Decision | 이 일의 근거가 된 결정 |
| arisesFrom | Decision -> Incident | 이 결정을 부른 사건 |
| triggers | Incident -> Decision/Practice/Initiative | 회고에서 나온 것 |

`supersedes` 와 `supersededBy` 중 **정본은 `supersedes` 쪽이다.** 새 결정이 무엇을
뒤집는지 알고 쓰이고, 옛 결정은 자기가 언제 뒤집힐지 모른다. 옛 결정 쪽에는 `status`
를 `superseded` 로 바꾸는 것으로 충분하고, 필요하면 백링크가 자연히 잡는다.

`decidedBy` 와 `decided` 중 **정본은 `decidedBy`, 즉 결정 쪽이다.** 결정은 닫히면
참여자가 고정되고 사람 노트는 계속 자란다.

`movesMetric` 과 `movedBy` 중 **정본은 `movesMetric`, 즉 이니셔티브 쪽이다.** 지표는
오래 살고 이니셔티브는 끝난다.

`arisesFrom` 과 `triggers` 는 방향이 다른 별개 술어다. 전자는 결정에서 사건을 가리키고
후자는 사건에서 파생물을 가리킨다. **정본은 `triggers` 쪽이다.** 회고를 쓰는 시점에
파생물이 한꺼번에 정해지기 때문이다.

### 시간과 유사

| 술어 | 방향 | 의미 |
|---|---|---|
| similarTo | Incident -> Incident | 같은 계열의 사건 |
| changes | Initiative -> System | 이 일이 건드리는 시스템 |
| movesMetric | Initiative -> Metric | 이 일이 움직이려는 지표 |
| movedBy | Metric -> Initiative | 역방향 |
| references | 다용도 | 참조 |

`similarTo` 는 무방향이라 한쪽에만 적으면 된다. 세 번째 같은 사건이 나면 그때 계열을
Decision 이나 Practice 로 승격할 신호다.

### 보조 술어

의미가 자명해 별도 정의를 두지 않고 어휘에만 등재한다.

`runbook` (System 이 가리키는 Practice), `tracker` (외부 티켓),
`relatedObjects` / `relatedViews` (다용도 연결).

## 인터페이스 (추상 타입)

여러 타입이 공통으로 갖는 구조. 폴더를 만들지 않고 이 표로만 존재한다.

### HasIdentity

구현: 8종 전부. [[personal-rag-schema]] 의 같은 이름 인터페이스에서 `identifiers` 와
`webPresence` 요구를 뺀 판이다.
`name` 또는 `slug`(필수), `aliases`, `tags`, `description`.

`identifiers` 는 Person 에만 쓴다. 슬랙 핸들과 깃허브 아이디를 그 표에 둔다. 나머지
타입은 `repo`, `dashboards` 같은 자기 프로퍼티로 충분하다.

### Temporal

구현: Team, Initiative, Decision, Incident. 타임라인 정렬의 기준이다.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| 시작 필드 | O | formedAt / startDate / decidedAt / startedAt |
| 종료 필드 |  | disbandedAt / endDate / resolvedAt |

Decision 은 종료 필드가 없다. 결정은 끝나지 않고 뒤집힐 뿐이라 `status` 가 그 자리를
대신한다.

### Owned

구현: Initiative, Practice, System, Incident, Metric. 소유 팀이 반드시 있는 것.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `owner` 또는 `ownedBy` 링크 | O | **Team 참조.** Person 이면 위반 |

Team, Person, Decision 은 Owned 가 아니다. 팀은 자기가 자기를 소유하지 않고, 사람은
소유 대상이 아니며, 결정은 팀 전체의 것이라 특정 소유자를 두면 그 사람만 뒤집을 수
있는 것처럼 읽힌다.

### Membered

구현: Person. 소속 이력을 갖는 것.

| 요구 프로퍼티 | 필수 | 설명 |
|---|---|---|
| `memberOf` 링크 | O | Team 참조 |
| `joinedAt` |  | 합류 |
| `leftAt` |  | 이탈. 비움 = 재직 중 |

## 값 타입

### DecisionStatus

- `proposed` 제안 - 논의 중. 아직 효력 없음
- `accepted` 채택 - 현재 유효
- `superseded` 대체됨 - 다른 결정이 덮었다. `supersededBy` 필수
- `reverted` 철회 - 대체가 아니라 그냥 되돌렸다. 이유를 본문에

`superseded` 와 `reverted` 를 구분하는 이유는 다음 사람이 읽을 때 의미가 완전히 다르기
때문이다. 전자는 더 나은 답을 찾은 것이고 후자는 그 방향 자체가 틀렸던 것이다.

### Severity

Incident 전용. `sev1` / `sev2` / `sev3` / `nearMiss`.

등급 기준은 팀마다 달라서 프리셋이 정하지 않는다. 대상 워크스페이스가 Practice
인스턴스로 자기 기준을 적고 Incident 개념 노트에서 그것을 가리킨다.

## 공유 프로퍼티

| 이름 | 타입 | 사용 | 설명 |
|---|---|---|---|
| `tags` | string[] | 전체 | 자유 분류 |
| `description` | text | 전체 | 짧은 설명 |
| `updated` | date | 전체 | 마지막 갱신 (GUIDE §6 이 bump) |
| `sources` | url[] | 전체 | 출처와 근거 |
| `owner` | -> Team | Owned 구현 타입 | 소유 팀 |
| `status` | enum | Initiative·Decision | 타입별 enum |

`confidence` 는 쓰지 않는다. 팀 운영 사실은 추정이 아니라 팀이 정한 것이라 신뢰도 축이
의미가 없다. 확실하지 않으면 Decision 의 `status: proposed` 로 둔다.

## 무결성 규칙 추가

코어 lint 규칙 1~6 에 더한다. 점검 방법은 [[team-ops-lint]].

7. 객체 인스턴스의 `type:` 은 허용 노트 타입에 등재된 값이어야 한다.
8. 객체 인스턴스는 필수 프로퍼티(PK, 각 타입의 O 표시)를 모두 갖는다.
9. `links:` 와 본문의 모든 위키링크는 실재하는 노트를 가리킨다.
10. 술어는 이 문서의 어휘에 있는 것만 쓴다.
11. 정방향과 역방향 술어를 같은 사실에 대해 양쪽 노트에 동시에 적지 않는다. 정본 방향은
    아래 표가 정본이다.

| 쌍 | 정본 (여기 적는다) | 비정본 |
|---|---|---|
| 소속 | Person 의 `memberOf` | Team 의 `hasMember` |
| 참여 | Initiative 의 `hasParticipant` | Person 의 `participatesIn` |
| 소유 | 각 객체의 `ownedBy` | Team 의 `owns` / `runs` / `pursues` |
| 결정 참여 | Decision 의 `decidedBy` | Person 의 `decided` |
| 결정 대체 | 새 Decision 의 `supersedes` | 옛 Decision 의 `supersededBy` |
| 사건 파생 | Incident 의 `triggers` | Decision 의 `arisesFrom` |
| 관측 | Metric 의 `observes` | System 의 `observedBy` |
| 당번 | System 의 `oncall` | Person 의 `oncallFor` |
| 지표 이동 | Initiative 의 `movesMetric` | Metric 의 `movedBy` |

**소속과 참여의 정본 방향이 서로 반대인 것에 주의한다.** 기준은 갱신이 덜 일어나는
쪽이고, 소속은 사람 쪽이 참여는 일 쪽이 덜 움직인다. 비정본 쪽은 사람이 읽을 때의 편의
링크이고 갱신 의무가 없다. 템플릿은 정본 슬롯만 제공한다.
12. 객체 인스턴스는 `broader` 를 갖지 않는다.

여기까지는 [[personal-rag-schema]] 와 같다. 아래 여섯이 이 프리셋 고유다.

13. **`ownedBy` 의 대상은 Team 이다.** 사람을 가리키면 위반이다. `oncall` 만 예외다.
14. **`status: superseded` 인 Decision 은 `supersededBy` 를 갖는다.** 무엇이 덮었는지
    모르면 그 결정은 열려 있는 것과 같다.
15. **Decision 은 `rationale` 과 `context` 를 갖는다.** 결론만 있는 결정 노트는
    티켓 제목과 다를 바 없다.
16. **1인칭 표현이 없다.** 본문에 "내가", "우리 팀장님" 같은 화자 의존 표현이 있으면
    위반이다. 여러 사람이 쓰는 워크스페이스에서 화자가 사라지면 대상이 사라진다.
17. **`leftAt` 이 있는 Person 은 `kind: alumni` 다.** 이탈자가 현재 구성원으로 잡히면
    온콜과 담당 조회가 틀린다.
18. **열린 Incident 에 `resolvedAt` 이 없다.** 반대로 `resolvedAt` 이 있는데 회고
    파생물(`triggers`)이 하나도 없는 sev1 은 경고다. 회고를 안 했거나 문서 안에만
    적혔다는 뜻이다.

16 과 18 은 구조 검사가 아니라 규율 검사다. 의도한 것이다. 이 프리셋이 실패하는 방식은
스키마 위반이 아니라 **사람 의존과 회고 유실**이고, lint 가 그것을 세지 않으면 아무도
세지 않는다.
