---
type: document
title: compliance 액션 어휘와 로그 형식
updated: 2026-11-14
---

# 액션 어휘와 로그 형식

Foundry 의 Action Type 은 객체 데이터를 통제된 방식으로 바꾸는 단위다. 단순 편집이
아니라 "어떤 의도의 변경인가"를 의미적으로 남긴다. 이 프리셋은 그 어휘를 프로토콜의
action-log 스트림(GUIDE §12.3, [[action-log]])에 얹는다.

프리셋은 로그의 **시간축 규칙을 바꾸지 않는다**. 하루 한 파일(`action-log/2026-09-10.md`),
append 전용, 상대시간 금지는 전부 프로토콜 소관이다. 프리셋이 더하는 것은 "무엇을
했다"를 부르는 이름 8개와 엔트리 한 줄의 내부 형식뿐이다.

이 도메인에서 로그는 편의가 아니라 **감사 대응 자산**이다. "언제 누가 이 의무의 상태를
met 으로 바꿨나" 는 감사에서 실제로 나오는 질문이고, 원본 노트는 값이 덮어써지므로
로그가 유일한 답이다. [[personal-rag-actions]] 에서는 이력 보존이 취향이지만 여기서는
요구사항이다.

## 액션 타입 8종

| 액션 | 파라미터 | 사이드 이펙트 |
|---|---|---|
| `createObject` | objectType, primaryKey, initialProperties | 없음 |
| `updateProperty` | target, field, from, to | 이전 값 보존(로그에 from 기록) |
| `addLink` | subject, predicate, object | 양쪽 중 정본 한쪽에만 기록 |
| `removeLink` | subject, predicate, object | 링크 해제 |
| `recordEvidence` | obligation, control, coversFrom, coversTo, location, kind | createObject:Evidence, 링크 evidenceFor·producedBy, Obligation.status 재산정 |
| `raiseFinding` | audit, affects, severity, raisedAt, dueAt, owner | createObject:Finding, 링크 raisedBy·affects·ownedBy |
| `closeFinding` | target, closedAt, resolvedBy | Finding.closedAt 기록, 시정 증거 연결 |
| `supersedeObject` | oldTarget, newTarget, effectiveFrom | 신규 인스턴스 + supersedes 링크. 이전 판을 지우지 않는다 |

### createObject

새 인스턴스를 등록한다. 검증: 같은 폴더에 동일 PK 가 있으면 거부하고 `updateProperty`
로 처리한다. 해당 타입의 필수 프로퍼티가 다 채워져 있어야 한다.

Obligation 을 만들 때는 `requiredBy` 가 함께 있어야 한다(규칙 14). 근거 없는 의무는
어디서 왔는지 알 수 없고, 나중에 근거를 붙이려 하면 아무도 기억하지 못한다.

### recordEvidence

이 프리셋에서 가장 자주 도는 액션이다. 한 액션으로 Evidence 객체를 만들고 Obligation 과
Control 로 링크를 걸고, 그 결과로 Obligation 의 `status` 가 바뀔 수 있다.

부수 효과가 셋이라 로그에는 recordEvidence 한 줄로 남기고, 갱신 원본 항목에 Evidence
노트와 상태가 바뀐 Obligation 노트 경로를 함께 적는다.

**`status` 는 이 액션이 바꾼다.** 사람이 따로 판단해 적는 칸이 아니다. 증거를 붙였는데 기간이
의무 주기를 덮지 못하면 `met` 이 아니라 `partial` 이다(규칙 15, 16). 상태를 손으로
`met` 으로 올리고 싶으면 그것은 recordEvidence 가 아니라 updateProperty 이고, 그때는
로그에 왜 그렇게 판단했는지 적는다.

### raiseFinding

지적사항을 제기한다. `owner` 와 `dueAt` 없이 만들지 않는다. 책임과 기한이 없는 지적은
추적되지 않고, 추적되지 않는 지적은 다음 감사에서 그대로 다시 나온다.

`affects` 는 사슬의 어느 마디가 끊겼는지를 가리킨다. Obligation 이 없어서 난 지적,
Control 이 안 돌아서 난 지적, Evidence 가 없어서 난 지적은 시정 방법이 전부 다르다.

### closeFinding

`closedAt` 을 적고 `resolvedBy` 로 시정을 증명하는 Evidence 를 건다. **증거 없이 닫지
않는다.** 증거 없는 종결은 지적사항을 없앤 것이 아니라 숨긴 것이다.

시정이 아직 안 됐는데 기한만 미루는 경우는 closeFinding 이 아니라
`updateProperty <Finding>.dueAt` 이다. 로그가 이 둘을 구분해야 "몇 번 연장됐나" 를
셀 수 있다.

### supersedeObject

법령 개정과 규정 개정을 처리한다. **덮어쓰지 않는다.** 새 인스턴스를 만들고 새 판이
이전 판을 `supersedes` 로 가리키며, 이전 판의 `effectiveTo` 에 폐지일을 적는다.

이전 판을 지우면 그 판이 유효하던 기간의 Evidence 가 근거를 잃는다. 감사는 대개 과거
기간을 보므로, 지금 유효한 규정만 남긴 워크스페이스는 감사에 쓸 수 없다.

삭제는 이 프리셋에 없다. 마운트가 삭제를 거부하는 것과 별개로, 폐기된 객체도 자산이다.

## 엔트리 형식

프로토콜의 엔트리 골격(무엇 / 갱신 원본 / 출처 / 확인)을 유지하고, "무엇" 한 줄 안에 액션
타입과 대상을 앞세운다.

```
## 2026-09-10
- 무엇: createObject Obligation/[[분기-접근권한-검토]] - 개인정보보호법 29조에서 도출
  - 갱신 원본: objects/obligations/분기-접근권한-검토.md
  - 출처: 법무팀 검토의견 (2026-09-08)
  - 확인: 직접 확인
- 무엇: recordEvidence [[2026Q2-IAM-검토결과]] -> [[분기-접근권한-검토]], 2026-04-01~2026-06-30
  - 갱신 원본: objects/evidence/2026Q2-IAM-검토결과.md, objects/obligations/분기-접근권한-검토.md
  - 출처: 보안팀 제출 (IAM 리포트 승인 이력)
  - 확인: 직접 확인
- 무엇: updateProperty [[분기-접근권한-검토]].status partial -> met
  - 갱신 원본: objects/obligations/분기-접근권한-검토.md
  - 출처: 위 증거 등록의 결과
  - 확인: 직접 확인
- 무엇: raiseFinding [[F-2026-003]] - [[분기-접근권한-검토]] 2025Q4 증거 누락, major, 기한 2026-10-31
  - 갱신 원본: objects/findings/F-2026-003.md, objects/audits/2026-1H-내부감사.md
  - 출처: 2026 상반기 내부감사 결과보고서
  - 확인: 직접 확인
- 무엇: supersedeObject [[개인정보-처리방침-운영규정-v3]] -> [[개인정보-처리방침-운영규정-v4]]
  - 갱신 원본: objects/regulations/개인정보-처리방침-운영규정-v4.md, objects/regulations/개인정보-처리방침-운영규정-v3.md
  - 출처: 2026-09-01 규정심의위원회 의결
  - 확인: 보고됨(준법감시인)
```

규칙:
- 액션 타입은 표의 8개 이름 그대로 쓴다. 임의 동사를 쓰면 로그가 grep 되지 않는다.
- `updateProperty` 는 `대상.필드 이전 -> 이후` 형태로 이전 값을 남긴다. 원본에서는
  값이 덮어써지므로 로그가 유일한 이력이다.
- 대상은 위키링크로 적어 객체와 로그가 서로 도달 가능하게 한다.
- 상대 시간은 절대 날짜로 변환한다.
- **출처를 비우지 않는다.** 다른 프리셋에서는 권장이지만 여기서는 필수다. 컴플라이언스
  기록의 값은 근거에 있고, 근거 없는 상태 변경은 감사에서 그대로 지적으로 돌아온다.
- 담당자 이름을 로그에 적어도 객체에는 넣지 않는다. 책임은 Unit 이 진다(규칙 13).

## Finding 으로 승격하는 기준

**모든 미비가 지적사항이 되지는 않는다.** 로그는 변경의 흔적이고 Finding 은 독립
라이프사이클과 시정 기한을 갖는 결함이다. 둘을 섞으면 두 가지가 동시에 망가진다.
사소한 것까지 Finding 이 되면 열린 지적 목록이 잡음으로 차서 진짜 급한 것이 묻히고,
반대로 아무것도 Finding 이 안 되면 시정이 추적되지 않는다.

다음 중 하나면 승격한다.

- **외부에 설명해야 한다.** 감사인, 규제기관, 인증심사원이 물었거나 물을 만한 결함이다.
- **시정에 기한과 책임 주체가 필요하다.** 지금 이 자리에서 못 고치고 누가 언제까지
  고칠지 정해야 한다.
- **사슬이 끊겨 있다.** 의무에 통제가 없거나, 통제에 증거가 없거나, 근거 없는
  `notApplicable` 이다. lint 규칙 14~18 이 잡는 것들이 대체로 여기 해당한다.
- **재발이다.** 이전 점검에서 같은 것이 나왔다. 한 번은 실수지만 두 번은 결함이다.

승격하지 않는 예: 오타 수정, 담당자 변경 반영, 링크 한 줄 추가, 증거 위치 경로 갱신,
아직 기한이 남은 정기 의무의 미이행. **기한 전의 미이행은 결함이 아니다.** 분기 의무의
증거가 분기 종료 직후에 없는 것은 정상이고, `dueRule` 의 유예 기간이 지나야 결함이다.
이 구분을 놓치면 Finding 이 매 분기 초마다 무더기로 생긴다.

애매하면 로그 한 줄로 두고 다음 점검 때 다시 본다. Finding 은 나중에 올릴 수 있지만
한 번 올린 Finding 을 조용히 내리기는 어렵다.

## 능동적 축적과의 접점

GUIDE §12.1 트리거가 발화하면 §12.2 라우팅으로 갈린다. 이 프리셋을 쓰는 워크스페이스
에서 라우팅은 이렇게 구체화된다.

- 새 법령·규정·의무·통제·점검 등장 -> `objects/<type>/` 에 인스턴스 생성
  (createObject) + 로그 한 줄.
- 통제가 돌았다는 기록이 들어옴 -> recordEvidence + 로그 한 줄. Obligation 의 상태가
  함께 움직인다. 이중 쓰기다.
- 법령이나 규정이 개정됨 -> supersedeObject + 로그 한 줄. 그리고 **아래로 전파를
  확인한다.** 개정된 조문에서 도출된 Obligation 이 아직 유효한지 훑는다. 이 단계를
  빠뜨리면 폐지된 근거에 매달린 의무가 남는다.
- 점검에서 결함이 나옴 -> 위 승격 기준으로 갈라 raiseFinding 또는 로그 한 줄.
- 담당 조직 변경 -> Unit 노트의 `currentHolder` 만 갱신(updateProperty). 사슬의 링크는
  건드리지 않는다. 그러라고 Unit 을 둔 것이다.
- 사용자 선호·진행 상태 -> `memory/` (객체가 아니다).
- 큐레이션이 바뀔 만한 변경 -> 같은 작업에서 관련 `object-sets/`, `object-views/`
  갱신. 라이브 뷰가 없으니 이 단계를 빠뜨리면 이행 현황표가 스테일해진다.
