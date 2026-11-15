---
type: document
title: compliance 대상 워크스페이스 레이아웃
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
    _schema/concept-scheme.md      코어 스킴. 여기에 프리셋 확장을 병합
    _concepts/                     대응 폴더 없는 추상 개념
  memory/                          LLM 메모리 레이어 (프로토콜 소관)
  action-log/
    action-log.md                  개념 노트
    2026-09-10.md                  날짜 파일(하루 하나). 액션 어휘는 compliance-actions 참조
  objects/
    compliance-chain.md            폴더 개념. broader = WS 의 top concept
    statutes/
      statute.md                   폴더 개념 (타입 정의 겸용). broader = compliance-chain
      개인정보보호법-29조.md          인스턴스. 위치로 분류
    regulations/
      regulation.md
      <부속물 많은 규정>/
        <같은 이름>.md             인덱스 노트(PK)를 폴더 안에 동명으로
        <개정 대비표·해설 노트>
    obligations/
      obligation.md
    controls/
      control.md
    evidence/
      evidence.md                  폴더만 단수형. 영어에서 셀 수 없는 명사다
    audits/
      audit.md
    findings/
      finding.md
    units/
      unit.md
  object-sets/
    object-set.md                  폴더 개념. broader = compliance-chain
    <집합>.md                      점검 범위 묶음. 큐레이트 모음 또는 필터 명세
  object-views/
    object-view.md                 폴더 개념. broader = compliance-chain
    <뷰>.md                        감사 대응 뷰, 이행 현황표, 사슬 추적 출력물
  datasources/
    datasource.md                  폴더 개념. broader = compliance-chain
    <출처>.md                      법령 원문과 증거 원본의 인덱스 (원문 비복제)
```

폴더명은 [[compliance-object-types]] 의 타입 표와 같다. `evidence` 만 단수형이고
나머지 일곱은 복수형이다. 개념 노트 파일명은 전부 단수형 개념 id 다.

## 분류가 성립하는 방식

1. **위치(1순위)**: `objects/obligations/` 안의 md 는 개념 obligation 소속이다.
   frontmatter 에 `subject` 를 적지 않아도 된다. 파일을 다른 타입 폴더로 옮기면 그것이
   재분류다.
2. **폴더 중첩 = broader**: `objects/obligations/` 가 `objects/` 안에 있으므로
   obligation 의 broader 는 compliance-chain 이다. 개념 노트 frontmatter 에 명시한다.
3. **frontmatter**: 한 인스턴스가 두 타입에 걸치는 예외적 경우에만 `subject` 로 다중
   소속을 적는다. 기본은 위치 하나로 끝낸다. 이 도메인에서 다중 소속의 유혹이 가장 큰
   것은 Obligation 과 Control 인데, 그것은 다중 소속이 아니라 분류 실패다. 판별 기준은
   [[compliance]] 의 "없어져도 되는 쪽이 Control 이다".
4. **비-md**: pdf, xlsx, 이미지는 메타를 붙이지 않는다. 관련 객체의 서브폴더에 두고
   인덱스 노트에서 위키링크로 언급한다. 다만 증거 원본과 규정 정본은 워크스페이스에
   들이지 않는 것이 기본이다([[compliance]] "증거를 워크스페이스에 복사하지 않는다").

## 타입 폴더 = 개념 노트가 겸하는 두 역할

`objects/obligations/obligation.md` 한 파일이 (a) 폴더 obligation 의 개념 노트이고
동시에 (b) Obligation 객체 타입의 정의(프로퍼티 표, PK, 구현 인터페이스, 허용 링크)다.

이렇게 두는 이유: 에이전트가 `objects/obligations/` 를 읽으면 스키마와 인스턴스가 같은
컨텍스트에 들어온다. 타입 정의를 확인하러 다른 트리로 점프하지 않는다.

정의 본문의 표준 형태는 [[compliance-object-types]] 에 타입별로 다 적혀 있다. 적용 시
그 내용을 각 개념 노트 본문으로 옮긴다.

## objects/ 를 남긴 이유

`statutes/` 를 WS 루트에 바로 두지 않고 `objects/` 아래 둔다. 그러면 `objects/` 폴더가
개념 compliance-chain 을 담당해서, 8개 타입의 broader 가 한 노드로 모인다. 루트에
흩으면 타입 8개가 각각 WS top concept 에 직결돼 그래프가 평평해지고, 프리셋을 적용한
부분과 워크스페이스 고유 개념이 구분되지 않는다.

이 프리셋에는 루트 객체가 없다([[compliance]] "원본 대비" 1번). 그래서 `objects/` 가
담당하는 개념이 더 중요하다. compliance-chain 이 사슬 전체를 가리키는 유일한 진입점
이고, `CONTEXT.md` 가 한 줄로 가리키는 것도 이 노트다.

## 부속물이 쌓이는 객체의 서브폴더 규칙

기본은 `objects/<type>/<PK>.md` 단일 파일이다. 부속 자료(개정 대비표, 조문 해설, 회차별
점검 기록)가 여러 개 쌓이면 **같은 이름의 서브폴더**를 만들고 인덱스 노트(PK)를 그 안에
**같은 파일명으로** 둔다. 위키링크는 파일명으로 해석되니 기존 링크는 안 깨진다.

```
objects/regulations/개인정보-처리방침-운영규정/
  개인정보-처리방침-운영규정.md      인덱스(PK), 규정의 정본
  2026-개정-대비표.md                부속 노트
  법무검토-의견.md                   부속 노트
```

주의: 이 서브폴더는 개념 폴더가 아니다. 개념 노트를 두지 않으며, 안의 파일은 상위 타입
폴더가 아니라 **이 서브폴더 위치**로 분류된다. 위치만으로는 소속이 결정되지 않으므로
frontmatter 로 보완한다.

**부속 노트는 두 키를 병기한다.** 둘은 서로 다른 일을 하므로 한쪽으로 줄이지 않는다.

| 키 | 값 | 무엇을 위한 것인가 |
|---|---|---|
| `subject` | `["[[regulation]]"]` | 개념 소속. lint 의 고아 검사가 보는 것 |
| 상위 타입명 키 (`regulation:` 등) | `"[[<인덱스 노트 PK>]]"` | 이 서브폴더의 어느 인덱스에 딸렸는지 |

`subject` 는 타입 개념(단수형 개념 id)을 가리키고, 상위 타입명 키는 인스턴스(인덱스
노트)를 가리킨다. 가리키는 대상이 개념과 인스턴스로 다르므로 중복이 아니다. 키 이름은
상위 인덱스의 타입을 소문자 단수로 쓴다. Audit 서브폴더의 부속 노트면 `audit:` 다.

인덱스 노트는 파일명이 곧 PK 이므로 예외 없이 `subject` 를 적고, 자기 자신을 가리키는
상위 키는 적지 않는다. 실제 형태와 점검 명령은 [[compliance-lint]] 의 "부속 서브폴더의
고아 방지".

서브폴더를 쓰지 말아야 하는 경우가 하나 있다. **개정된 규정의 이전 판**은 부속물이
아니라 별개 인스턴스다. 같은 폴더에 나란히 두고 `supersedes` 로 잇는다
([[compliance-schema]] "시간과 개정"). 서브폴더에 밀어넣으면 이전 판이 조회에서
사라지고, 그 판이 유효하던 기간의 증거가 근거를 잃는다.

## Audit 회차와 Finding 을 어디 두는가

Audit 은 회차마다 새 인스턴스다. `2026-1H-내부감사` 처럼 시점을 PK 에 넣는다. 같은
점검을 매년 돌아도 한 노트를 덮어쓰지 않는다. 덮어쓰면 작년 지적사항의 출처가 사라진다.

Finding 은 Audit 서브폴더에 넣지 않고 `objects/findings/` 에 독립으로 둔다. 지적사항은
감사가 끝난 뒤에도 시정 기한을 달고 혼자 굴러가기 때문이다([[compliance-object-types]]
Finding 절). 소속은 `raisedBy` 링크가 담당한다.

## 프리셋이 건드리지 않는 것

`CONTEXT.md` 의 프로토콜 항목, 포털(`AGENTS.md`, `CLAUDE.md`), `CONTEXT_GUIDE.md`, `memory/`, action-log 의 시간축 규칙은 전부 프로토콜
소관이다. 프리셋은 `objects/`, `object-sets/`, `object-views/`, `datasources/` 를
추가하고, `_project.md` 의 suitability 와 `_schema/` 에 확장을 병합하고, action-log 에
액션 어휘를 얹는 것까지만 한다.
