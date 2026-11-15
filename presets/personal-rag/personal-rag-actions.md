---
type: document
title: personal-rag 액션 어휘와 로그 형식
updated: 2026-11-14
---

# 액션 어휘와 로그 형식

Foundry 의 Action Type 은 객체 데이터를 통제된 방식으로 바꾸는 단위다. 단순 편집이
아니라 "어떤 의도의 변경인가"를 의미적으로 남긴다. 이 프리셋은 그 어휘를 프로토콜의
action-log 스트림(GUIDE §12.3, [[action-log]])에 얹는다.

프리셋은 로그의 **시간축 규칙을 바꾸지 않는다**. 하루 한 파일(`action-log/2026-08-18.md`),
append 전용, 상대시간 금지는 전부 프로토콜 소관이다. 프리셋이 더하는 것은 "무엇을
했다"를 부르는 이름 7개와 엔트리 한 줄의 내부 형식뿐이다.

원본은 `action-log/YYYY/YYYY-MM-DD.md` 날짜 폴더를 썼다. 샤딩 단위(하루)는 같지만
폴더를 만들지 않는 것이 차이다. 구조 우선 온톨로지에서 날짜 폴더는 개념으로 오인돼
broader 그래프를 오염시키고 안의 파일을 고아로 만든다. 날짜를 파일명에 통째로 넣으면
폴더 없이 같은 granularity 를 얻는다.

## 액션 타입 7종

| 액션 | 파라미터 | 사이드 이펙트 |
|---|---|---|
| `createObject` | objectType, primaryKey, initialProperties | 없음 |
| `recordEvent` | title, datetime, place, participants, category, summary | createObject:Event, 링크 involvesPerson·locatedAt |
| `updateProperty` | target, field, from, to | 이전 값 보존(로그에 from 기록) |
| `addLink` | subject, predicate, object | 양쪽 중 정본 한쪽에만 기록 |
| `removeLink` | subject, predicate, object | 링크 해제 |
| `publishArtifact` | target, publishedAt, url | Artifact 를 공개 상태로 전환 |
| `archiveObject` | target, reason | 삭제하지 않고 격리 (status 갱신) |

### createObject

새 인스턴스를 등록한다. 검증: 같은 폴더에 동일 PK 가 있으면 거부하고
`updateProperty` 로 처리한다. 해당 타입의 필수 프로퍼티가 다 채워져 있어야 한다.

### recordEvent

한 액션으로 Event 객체를 만들고 관련 Person/Place 링크까지 연결한다. 부수 효과가
셋이라 로그에는 recordEvent 한 줄로 남기고, 갱신 원본 항목에 Event 노트와 링크가
붙은 노트 경로를 함께 적는다.

### archiveObject

마운트가 삭제를 거부하는 것과 별개로, 이 프리셋은 객체를 **삭제하지 않는다**.
식별자 이력과 마찬가지로 폐기된 객체도 자산이다. `status` 또는 `tags: [archived]` 로
격리하고 로그에 이유를 남긴다.

## 엔트리 형식

프로토콜의 엔트리 골격(무엇 / 갱신 원본 / 출처 / 확인)을 유지하고, "무엇" 한 줄 안에 액션
타입과 대상을 앞세운다.

```
## 2026-08-18
- 무엇: createObject Person/[[김아무개]] - YC SF 행사에서 만남
  - 갱신 원본: objects/people/김아무개.md
  - 출처: 사용자 발화 (2026-08-18 세션)
  - 확인: 보고됨(사용자)
- 무엇: recordEvent [[2026-yc-sf-meetup]] - 참석자 12명, 본인 발표
  - 갱신 원본: objects/events/2026-yc-sf-meetup.md, objects/people/김아무개.md
  - 출처: 사용자 발화
  - 확인: 보고됨(사용자)
- 무엇: updateProperty [[프루퍼]].headquarters 성수 -> 역삼
  - 갱신 원본: objects/organizations/프루퍼.md
  - 출처: 사업자등록증 (Attachments 아님, 조직 폴더 동거)
  - 확인: 직접 확인
```

규칙:
- 액션 타입은 표의 7개 이름 그대로 쓴다. 임의 동사를 쓰면 로그가 grep 되지 않는다.
- `updateProperty` 는 `대상.필드 이전 -> 이후` 형태로 이전 값을 남긴다. 원본에서는
  값이 덮어써지므로 로그가 유일한 이력이다.
- 대상은 위키링크로 적어 객체와 로그가 서로 도달 가능하게 한다.
- 상대 시간은 절대 날짜로 변환한다.

## Event 객체로 승격하는 기준

모든 액션이 Event 가 되지는 않는다. 로그는 변경의 흔적이고 Event 는 독립 의미를 갖는
사건이다. 다음 중 하나면 승격한다.

- 여러 객체가 함께 얽힌다 (사람 여럿 + 장소 + 프로젝트).
- 이후 다른 사건의 원인이 된다 (`triggers` 를 걸 만하다).
- 나중에 그 자체를 참조해 이야기할 일이 있다 (자기소개, 타임라인, 포트폴리오).

승격하지 않는 예: 오타 수정, 필드 하나 채움, 링크 한 줄 추가. 로그 한 줄로 끝낸다.

## 능동적 축적과의 접점

GUIDE §12.1 트리거가 발화하면 §12.2 라우팅으로 갈린다. 이 프리셋을 쓰는 워크스페이스
에서 라우팅은 이렇게 구체화된다.

- 새 인물/조직/프로젝트/사건 등장 -> `objects/<type>/` 에 인스턴스 생성
  (createObject) + 로그 한 줄.
- 기존 객체의 사실 변경 -> 그 원본 갱신(updateProperty) + 로그 한 줄. 이중 쓰기다.
- 사용자 정체성/선호/피드백/진행상태 -> `memory/` (객체가 아니다).
- 관계가 새로 드러남 -> 정본 쪽 노트에 링크 추가(addLink) + 로그 한 줄.
- 큐레이션이 바뀔 만한 변경 -> 같은 작업에서 관련 `object-sets/`, `object-views/`
  갱신. 라이브 뷰가 없으니 이 단계를 빠뜨리면 뷰가 스테일해진다.
