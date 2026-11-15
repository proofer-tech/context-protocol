---
type: concept
scheme: context-protocol
pref_label_ko: 퍼스널 RAG 프리셋
pref_label_en: Personal RAG preset
broader: "[[preset-library]]"
related:
definition: 한 사람을 디지털 트윈으로 표현하는 개인 지식그래프 프리셋. Palantir Foundry 객체 모델(객체/프로퍼티/링크/액션)을 구조 우선 온톨로지로 번역해 사람·조직·프로젝트·사건·장소·아이디어·산출물 7종 타입과 술어 어휘, 템플릿, 적용 절차를 제공한다.
updated: 2026-09-10
---

# 퍼스널 RAG 프리셋 (폴더 개념)

이 노트는 `presets/personal-rag/` 폴더의 개념 노트다. 폴더 중첩이 broader 를 뜻하니
이 프리셋은 [[preset-library]] 아래에 있다. 이 폴더 안의 파일은 위치만으로 이 개념에
속하며 전부 설계 문서다. 여기에 실제 인물/프로젝트 인스턴스를 만들지 않는다.

## 무엇을 위한 프리셋인가

한 사람의 생애 기록, 관계망, 포트폴리오 자료를 하나의 워크스페이스에 모아 에이전트가
"이 사람에 대해" 답할 수 있게 만드는 개인 RAG 구조다. 답변의 근거가 흩어진 대화 로그나
휘발성 라이브 소스가 아니라, 타입이 있는 md 원본 집합이 된다.

적합: 자기소개/포트폴리오 생성, 관계망 질의("누구를 언제 어떻게 알게 됐나"), 경력
타임라인, 산출물 아카이브, 개인 브랜딩 자료의 단일 출처.

부적합: 조직 공용 지식베이스(사람 1인 루트 가정이 깨진다), 휘발성 운영 데이터,
문서 원문 대량 적재(원문은 datasource 인덱스로 두고 사실만 객체에 반영한다).

## 계보

원본은 `hsol-info-blob/vault` 다. Palantir Foundry Object Backend 의 의미적 구성요소
(object, property, link)와 동적 구성요소(action, function)를 md vault 로 옮긴 구조로,
실사용 검증을 거쳤다. 이 프리셋은 그 설계를 context-protocol v4 구조 우선
온톨로지로 번역한 것이다.

## 무엇을 설치하는가

- 객체 타입 7종: Person, Organization, Project, Event, Place, Idea, Artifact.
  각 타입은 대상 워크스페이스에서 **폴더 개념**이 되고 인스턴스는 그 폴더에 산다.
- 술어 어휘: 관계 링크 타입(정방향/역방향/보조), 값 타입, 공유 프로퍼티(identifiers,
  webPresence).
- 액션 어휘 7종과 action-log 엔트리 형식.
- 타입별 템플릿 7종.
- 큐레이션 레이어: object-sets(모음), object-views(출력 뷰), datasources(외부 출처
  인덱스).
- 초기 문답 절차: AskUserQuestion 라운드로 빈 그래프를 채우는 인테이크 질문지.
- 사전 설정 변형 3종: 개인 아카이브형, 프로젝트 기록형, 고객 자료형. 타입과 술어는
  그대로 두고 주축 타입, 조회 규칙, 인테이크 라운드 순서만 분기한다.

상세는 [[personal-rag-layout]], [[personal-rag-object-types]],
[[personal-rag-schema]], [[personal-rag-actions]] 를 본다. 적용은
[[personal-rag-apply]], 초기 채우기는 [[personal-rag-intake]], 용도별 사전 설정은
[[personal-rag-variants]], 점검은 [[personal-rag-lint]].

## 구조만 얹으면 비어 있다

이 프리셋의 실패 모드는 "구조는 완벽한데 객체가 없음"이다. 적용 절차가 끝나면 폴더 11개와
개념 노트는 서지만 인스턴스는 루트 Person 하나다. 나머지는 GUIDE §12 능동적 축적이 채우기로
돼 있는데, 축적은 대화가 일어나야 작동한다. 이 파일 묶음만 받은 사람은 아직 대화 이력이
없으므로 그 구간이 비어 있다.

[[personal-rag-intake]] 가 그 부트스트랩 구간만 메운다. 전수 조사가 아니라 "루트에서 2홉으로
닿는 객체가 열 개쯤" 되는 상태까지만 만들고 축적에 인계한다. 이 구조를 처음 보는 사용자는
무엇을 적어야 하는지 모르므로 에이전트가 선택지로 물어야 한다는 것이 그 문서의 전제다.

## 7종은 출발점이다

타입 목록을 울타리로 읽으면 안 된다. 7종 중 어디에도 맞지 않는 대상이 나오면 가장
가까운 타입에 밀어넣는 대신 **새 타입 폴더를 만든다**. 프로토콜의 구조 생성 원칙이
프리셋 층에서 그대로 적용된다. 판단 기준과 반려동물(Pet) 워크드 예시는
[[personal-rag-object-types]] 의 "7종에 없는 것이 나오면 타입을 만든다".

특히 `kind` enum 을 늘려 해결하려는 충동을 경계한다. kind 는 같은 종류 안의 갈래이고,
종류가 다르면 타입이다.

## 원본 대비 편차 (의도된 것)

| # | 원본 (hsol-info-blob) | 이 프리셋 | 이유 |
|---|---|---|---|
| 1 | `_ontology/` 스키마 트리와 `objects/` 인스턴스 분리 | 타입 정의가 인스턴스 폴더 안의 개념 노트로 동거 | v4 §10: 폴더가 개념, 전용 인덱스 트리 없음. 에이전트가 폴더 하나 읽으면 스키마와 인스턴스를 함께 얻는다 |
| 2 | link-types/interfaces/value-types/shared-properties 각각 별도 노트 | [[personal-rag-schema]] 한 파일로 통합 | 술어는 폴더를 가질 수 없는 스키마다. 헤드리스 에이전트에겐 1 read = 전체 어휘가 유리 |
| 3 | 객체 타입 `Concept` | `Idea` 로 개칭 | v4 에서 concept 은 분류 노드를 뜻한다. 같은 단어를 두 의미로 쓰면 lint 와 사람이 모두 헷갈린다. kind 값(value/belief/interest/skill/topic)은 그대로 |
| 4 | `action-log/YYYY/YYYY-MM-DD.md` 날짜 폴더 | `action-log/YYYY-MM-DD.md` 평면 날짜 파일 | 하루 단위 샤딩은 같지만 폴더를 만들지 않는다. 날짜 폴더는 개념으로 오인돼 broader 그래프를 오염시키고 lint 규칙 1~3 과 충돌한다([[action-log]]) |
| 5 | `.base` 라이브 테이블, Dataview 쿼리(`functions/`) | 제외. 정적 md 인덱스 + grep 레시피([[personal-rag-lint]]) | 대상은 헤드리스 에이전트다. Obsidian 런타임 없이 성립해야 한다 |
| 6 | `Attachments/` 단일 미디어 폴더 | 객체와 동거. 부속물이 쌓이는 객체는 동명 서브폴더를 갖고 인덱스 노트를 그 안에 둔다 | 원본의 Project storage 규칙을 전 타입으로 일반화. 위치 = 분류이므로 첨부도 소속을 갖는다 |
| 7 | 객체 타입 Mentee, NewsArticle | 제외 | 개인화된 파생 타입이다. 필요하면 [[personal-rag-schema]] 의 타입 추가 절차로 확장한다 |

## 이 번역이 원본만큼 동작하는가

동등하게 동작하는 부분: 조회(폴더 위치 + 파일명 + grep), 분류(위치 우선), 관계 추적
(위키링크), 시간축(action-log), 템플릿 기반 생성. 인스턴스 frontmatter 는 원본과
거의 같은 모양을 유지한다(`type: Person` 그대로 쓴다, [[personal-rag-schema]] 참조).

손실 두 가지가 실재한다.

1. 라이브 테이블이 없다. 원본은 Dataview 와 `.base` 가 object-sets/object-views 를
   자동 갱신해 줬다. 여기서는 그 두 레이어가 손으로 유지되는 정적 md 라 방치하면
   스테일해진다. 완화는 두 겹이다. (a) 동적 집합은 결과를 박아두지 않고 **필터 명세**
   로 적어 에이전트가 읽을 때 grep 으로 재계산한다([[personal-rag-lint]]).
   (b) GUIDE §12 능동적 축적이 객체를 바꿀 때 관련 뷰를 같은 작업에서 갱신하게 한다.
2. Foundry 폴더 대응이 1:1 이 아니다. link-types 13종이 각자 노트를 갖지 않고 표
   한 줄이 된다. 술어 하나에 긴 설명을 붙이기는 불편해졌다. 대신 어휘 전체를 한 번에
   읽는 이득을 얻는다.

얻는 것도 있다. 인스턴스가 자기분류되므로 파일을 옮기는 것이 곧 재분류다.
`objects/people/` 로 두 단계 내려가지 않고 첨부와 부속 노트가 객체 곁에 산다.
그리고 프리셋 전체가 코어 프로토콜의 lint 하나로 검증된다. 원본은 Obsidian 을 열어야
검증됐다.

요약하면 검색과 분류는 동등하고, 자동 갱신 뷰는 규율로 대체된다. 개인 RAG 의 주
사용자가 헤드리스 에이전트라면 순이득이다. Obsidian 그래프 뷰를 눈으로 쓰는 비중이
크다면 원본 쪽이 낫다.
