---
type: document
title: team-ops 대상 워크스페이스 레이아웃
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
    2026-09-10.md                  날짜 파일(하루 하나). 액션 어휘는 team-ops-actions 참조
  objects/
    team-knowledge.md              폴더 개념. broader = WS 의 top concept
    teams/
      team.md                      폴더 개념 (타입 정의 겸용). broader = team-knowledge
      플랫폼팀.md                  루트 Team 인스턴스. tags: [self, root]
      <스쿼드>.md                  하위 팀도 같은 타입
    people/
      person.md
      <이름>.md
    initiatives/
      initiative.md
      <slug>.md
      <부속물 많은 이니셔티브>/
        <같은 이름>.md             인덱스 노트(PK)를 폴더 안에 동명으로
        <설계 메모·측정 기록>
    decisions/
      decision.md
      <slug>.md
    practices/
      practice.md
      <slug>.md
    systems/
      system.md
      <slug>.md
    incidents/
      incident.md
      <slug>.md
      <타임라인 긴 장애>/
        <같은 이름>.md             인덱스(PK). 회고 본문
        <로그 발췌·그래프 캡처>
    metrics/
      metric.md
      <slug>.md
  object-sets/
    object-set.md                  폴더 개념. broader = team-knowledge
    <집합>.md                      온보딩 경로, 크리티컬 시스템 목록 등
  object-views/
    object-view.md                 폴더 개념. broader = team-knowledge
    <뷰>.md                        팀 소개, 시스템 지도, 분기 리뷰 등 출력물
  datasources/
    datasource.md                  폴더 개념. broader = team-knowledge
    <출처>.md                      지라, 깃허브, 슬랙 채널, 페이지듀티 인덱스 (원문 비복제)
```

## 분류가 성립하는 방식

1. **위치(1순위)**: `objects/decisions/` 안의 md 는 개념 decision 소속이다. frontmatter
   에 `subject` 를 적지 않아도 된다. 파일을 다른 타입 폴더로 옮기면 그것이 재분류다.
2. **폴더 중첩 = broader**: `objects/decisions/` 가 `objects/` 안에 있으므로 decision 의
   broader 는 team-knowledge 다. 개념 노트 frontmatter 에 명시한다.
3. **frontmatter**: 한 인스턴스가 두 타입에 걸치는 예외적 경우에만 `subject` 로 다중
   소속을 적는다. 기본은 위치 하나로 끝낸다.
4. **비-md**: 아키텍처 다이어그램, 대시보드 캡처, 슬라이드는 메타를 붙이지 않는다.
   관련 객체의 서브폴더에 두고 인덱스 노트에서 위키링크로 언급한다.

## 타입 폴더 = 개념 노트가 겸하는 두 역할

`objects/decisions/decision.md` 한 파일이 (a) 폴더 decision 의 개념 노트이고 동시에
(b) Decision 객체 타입의 정의(프로퍼티 표, PK, implements, 허용 링크)다. 스키마와
인스턴스가 같은 폴더에 산다.

이렇게 두는 이유: 에이전트가 `objects/decisions/` 를 읽으면 타입 정의와 실제 결정들이
같은 컨텍스트에 들어온다. 정의를 확인하러 다른 트리로 점프하지 않는다.

정의 본문의 표준 형태는 [[team-ops-object-types]] 에 타입별로 다 적혀 있다. 적용 시
그 내용을 각 개념 노트 본문으로 옮긴다.

## objects/ 를 남긴 이유

`teams/` 를 WS 루트에 바로 두지 않고 `objects/` 아래 둔다. 그러면 `objects/` 폴더가
개념 team-knowledge 를 담당해서, 8개 타입의 broader 가 한 노드로 모인다. 루트에 흩으면
타입 8개가 각각 WS top concept 에 직결돼 그래프가 평평해지고, 프리셋을 적용한 부분과
워크스페이스 고유 개념이 구분되지 않는다.

top 개념 이름이 `personal-knowledge-graph` 가 아니라 `team-knowledge` 인 것은 루트가
사람이 아니라 팀이기 때문이다. 이름이 사람 하나를 가리키면 그 사람이 떠날 때 top 개념
이 거짓이 된다.

## 여러 사람이 동시에 쓴다는 조건이 레이아웃에 주는 영향

[[team-ops]] 의 제약 3번(갱신 충돌을 전제한다)이 폴더 구조에 그대로 내려온다.
personal-rag 는 한 사람이 순차적으로 쓰므로 노트가 커져도 문제가 없었다. 여기서는
두 사람이 같은 날 같은 파일을 고치고, 마운트가 잠금을 제공하지 않으므로 나중에 쓴
쪽이 앞선 쪽을 덮는다. 레이아웃이 그 확률을 낮추는 첫 방어선이다.

**1. 노트를 잘게 쪼갠다.** 한 노트에 여러 사실을 몰지 않는다. 같은 시스템에 대한
소유, 의존, 온콜, 장애 이력, 지표를 System 노트 하나에 다 적으면 그 파일이 팀 전체의
쓰기 병목이 된다. 소유는 System 에, 장애는 Incident 에, 숫자는 Metric 에 나눠 두면
서로 다른 사람이 서로 다른 파일을 건드린다. 타입이 personal-rag 보다 하나 더 많은
것은 표현력 때문이 아니라 이 분산 때문이다.

**2. 서브폴더를 더 적극적으로 쓴다.** personal-rag 에서 동명 서브폴더는 부속물이
여러 개 쌓였을 때의 예외 조치였다. 여기서는 **여러 사람이 같은 대상에 붙을 것이
예상되면 부속물이 쌓이기 전에 미리 만든다.** 진행 중인 이니셔티브와 대응 중인 sev1
이 대표 사례다. 각자 자기가 만든 부속 노트에 쓰면 인덱스 노트는 링크 갱신만 받는다.

```
objects/incidents/2026-08-결제-지연/
  2026-08-결제-지연.md          인덱스(PK). 회고 정본. 타임라인과 rootCause
  대응-로그-발췌.md              대응자가 쓴다. subject 로 소속만 적는다
  큐-적체-그래프.png             관측 담당이 넣는다
```

**3. 추가만 하는 형태를 표보다 먼저 고른다.** 여러 사람이 한 노트의 같은 표를 고치면
행이 사라진다. 사람마다 한 줄씩 붙이는 성격의 기록은 표 대신 목록으로 두거나 부속
노트로 뺀다. 표는 한 사람이 유지 책임을 지는 자리에만 쓴다.

**4. 그래도 겹치는 파일이 있다.** 루트 Team 노트와 각 타입의 개념 노트가 그렇다.
이 파일들은 구조를 담고 사실을 담지 않으므로 갱신 빈도가 낮다. 낮게 유지하는 것이
설계다. 팀 노트에 구성원 명단을 박지 않는 이유가 여기 있다([[team-ops-schema]] 의
`memberOf` 정본 규칙).

## 부속물이 쌓이는 객체의 서브폴더 규칙

기본은 `objects/<type>/<PK>.md` 단일 파일이다. 부속 자료가 여러 개 쌓이거나 위 절의
사유로 미리 만드는 경우, **같은 이름의 서브폴더**를 만들고 인덱스 노트(PK)를 그 안에
**같은 파일명으로** 둔다. 위키링크는 파일명으로 해석되니 기존 링크는 안 깨진다.

```
objects/initiatives/결제-스트라이프-이관/
  결제-스트라이프-이관.md        인덱스(PK), 이니셔티브의 정본
  이관-절차-초안.md              부속 노트. frontmatter subject: 로 소속 명시
  현행-흐름도.png                비-md 첨부. 위치로 분류
```

주의: 이 서브폴더는 개념 폴더가 아니다. 개념 노트를 두지 않으며, 안의 파일은 상위 타입
폴더가 아니라 **이 서브폴더 위치**로 분류된다. lint 가 고아로 잡지 않게 하려면 부속
md 에 `subject: ["[[<type>]]"]` 를 적는다. 인덱스 노트는 파일명이 곧 PK 이므로 예외
없이 `subject` 를 적는다.

상위 인덱스 노트를 가리킬 때 `initiative:` 처럼 타입명을 딴 임의 키를 만들지 않는다.
술어 표에 없는 키는 규칙 10 위반이다. 다용도 연결로 등재된 `relatedObjects` 를 쓰거나
본문 위키링크로 가리킨다. 상세는 [[team-ops-lint]].

## 프리셋이 건드리지 않는 것

`CONTEXT.md` 의 프로토콜 항목, 포털(`AGENTS.md`, `CLAUDE.md`), `CONTEXT_GUIDE.md`, `memory/`, action-log 의 시간축 규칙은 전부 프로토콜
소관이다. 프리셋은 `objects/`, `object-sets/`, `object-views/`, `datasources/` 를
추가하고, `_project.md` 의 suitability 와 `_schema/` 에 확장을 병합하고, action-log 에
액션 어휘를 얹는 것까지만 한다.
