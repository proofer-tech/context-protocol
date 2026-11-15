---
type: document
title: team-ops 적용 절차
updated: 2026-10-29
---

# 적용 절차

이 문서는 4단계 중 3단계(프리셋 얹기)다. 사용자가 "team ops 프리셋으로 ~해줘" 라고
했을 때의 전체 순서는 [[preset-library]] 의 "프리셋 호출 계약"에 있다. 프리셋 찾기(1)
-> 프로토콜 설치(2) -> 이 문서(3) -> 기존 파일 정리(4). 4단계의 이동 정책도 그쪽에
있다. 여기서 다시 적지 않는다.

전제: 대상 워크스페이스에 context-protocol 이 이미 적용돼 있다(CONTEXT.md,
`_context-protocol/CONTEXT_GUIDE.md`(6.x 는 루트), memory/, action-log/, _project.md 존재). 없으면
CONTEXT_SETUP.md 로 먼저 프로토콜을 깔고 온다. 프리셋은 프로토콜 위에 얹는 레이어이고
프로토콜을 대체하지 않는다.

작업 도구는 하네스의 호스트 파일 도구다(GUIDE §5, Cowork 에서는 Desktop Commander). (proxy_mount: yes)
마운트는 삭제와 atomic-rename 을 거부하니 임시파일을 만들지 않고 rewrite/append 만 쓴다(GUIDE §4.5). 쓰기는
25~30줄 단위로 쪼갠다.

팀 워크스페이스 고유 전제 하나: **이 적용 작업 자체가 다른 사람이 쓰는 중인 공유
폴더에서 일어날 수 있다.** 적용 전에 사용자에게 지금 이 폴더를 쓰는 다른 세션이 있는지
확인하고, 있으면 시간을 잡아 한 번에 끝낸다. 반쯤 적용된 상태로 남겨두면 다른 사람이
그 위에 쓰기 시작한다.

## Step 0. 사전 확인

1. `_context-protocol/_schema/concept-scheme.md` 를 읽어 top concept 이름을 확인한다. Step 2 의
   `broader` 값이 된다.
2. `_context-protocol/_ontology.md` 를 읽어 기존 개념 트리를 파악한다. `objects`, `people`,
   `systems` 등 이름 충돌이 있는지 본다. 있으면 프리셋 폴더명을 조정하고 이 문서에
   기록한다.
3. `memory/MEMORY.md` 와 `_project.md` 를 읽는다(GUIDE §6: 쓰기 전 인덱스와 대상을
   먼저 읽는다).
4. **[[personal-rag]] 가 이미 얹혀 있는지 본다.** `objects/people/person.md` 가 있으면
   Person 타입이 충돌한다. 충돌은 프로퍼티 표 하나가 아니라 여섯 겹이다(주소,
   implements, 프로퍼티, `tags` 의미, 루트 마커, 템플릿 파일명). 표는
   [[team-ops-schema]] 의 충돌 절에 있고, 그 여섯을 하나씩 대조한 뒤에 판단한다.

   두 프리셋을 한 워크스페이스에 겹치는 것은 권장하지 않는다. 그래도 해야 하면
   **타입명만 바꾸는 것으로는 부족하다.** 넷을 함께 바꾸고 다섯 번째를 정리한다.

   | 바꿀 것 | 예 |
   |---|---|
   | 폴더명 | `objects/people/` -> `objects/members/` |
   | 개념 id 와 개념 노트 파일명 | `person` -> `member`, `members/member.md` |
   | 타입명 | `Person` -> `Member`. 술어 표의 range 도 같이 고친다 |
   | 템플릿 파일명 | `person.md.tpl` -> `member.md.tpl` |
   | 루트 마커 | `tags: [self, root]` 를 하나만 남긴다. 이 프리셋에서는 루트 Team 쪽이다 |

   넷 중 하나라도 빠지면 같은 폴더에 두 종류가 섞여 규칙 10 판정이 불가능해진다.
   바꾼 이름은 이 워크스페이스의 `_context-protocol/_schema/concept-scheme.md` 에 기록하고,
   [[team-ops-lint]] 의 명령에 박힌 경로도 같이 고쳐 쓴다.

## Step 1. 폴더 생성

```
objects/  objects/teams/  objects/people/  objects/initiatives/
objects/decisions/  objects/practices/  objects/systems/
objects/incidents/  objects/metrics/
object-sets/  object-views/  datasources/
```

`Attachments/` 는 만들지 않는다. 첨부는 관련 객체와 동거한다([[team-ops-layout]]).
`functions/` 도 만들지 않는다. Dataview 를 쓰지 않으므로 조회 레시피는
[[team-ops-lint]] 에 둔다.

## Step 2. 개념 노트 12개 작성

각 폴더에 개념 노트를 둔다. frontmatter 형식은 대상 워크스페이스의 기존 개념 노트와
동일하게 맞춘다(`type: concept`, `scheme:`, `pref_label_ko/en`, `broader`,
`definition`).

| 파일 | 개념 id | broader |
|---|---|---|
| `objects/team-knowledge.md` | team-knowledge | WS 의 top concept |
| `objects/teams/team.md` | team | team-knowledge |
| `objects/people/person.md` | person | team-knowledge |
| `objects/initiatives/initiative.md` | initiative | team-knowledge |
| `objects/decisions/decision.md` | decision | team-knowledge |
| `objects/practices/practice.md` | practice | team-knowledge |
| `objects/systems/system.md` | system | team-knowledge |
| `objects/incidents/incident.md` | incident | team-knowledge |
| `objects/metrics/metric.md` | metric | team-knowledge |
| `object-sets/object-set.md` | object-set | team-knowledge |
| `object-views/object-view.md` | object-view | team-knowledge |
| `datasources/datasource.md` | datasource | team-knowledge |

8개 타입 개념 노트의 본문에는 [[team-ops-object-types]] 의 해당 절(프로퍼티 표, PK,
implements, 허용 출력 링크)을 옮긴다. 개념 노트가 곧 타입 정의를 겸한다.

**허용 출력 링크의 "비정본" 표시를 지우지 말고 그대로 옮긴다.** 그 줄이 없으면 다음
사람이 역방향 술어를 정본으로 읽고 양쪽에 적어서 규칙 11 위반을 만든다. 표시를
지우는 것이 목록을 깔끔하게 만드는 것처럼 보이지만, 그 목록의 값이 정확히 그 표시에
있다. 정본 방향 요약표는 [[team-ops-schema]] 규칙 11 아래에 있다.

주의: `broader` 는 개념 하나만 가리킨다. top concept 은 WS 에 정확히 하나여야 하니
`team-knowledge` 를 새 top 으로 만들지 말고 기존 top 아래에 붙인다.

## Step 3. 스킴 확장 병합

`_context-protocol/_schema/concept-scheme.md` 를 수정한다.

1. 허용 노트 타입 목록에 `Team, Person, Initiative, Decision, Practice, System,
   Incident, Metric` 을 추가하고 "lint 상 document 로 취급, broader 없음"을 명기한다.
2. 허용 술어 표 아래에 `links` 행을 추가한다: "Link 맵. 객체 관계. 어휘는
   presets/team-ops/team-ops-schema.md".
3. 무결성 규칙에 규칙 7~18([[team-ops-schema]])을 추가한다. 16 과 18 은 구조 검사가
   아니라 규율 검사임을 함께 적는다. 적지 않으면 다음 사람이 "자동으로 못 잡으니
   빼자"고 판단한다.

코어 규칙 1~6 은 건드리지 않는다.

## Step 4. 템플릿 배치

`presets/team-ops/templates/*.md.tpl` 을 대상 WS 의 `_context-protocol/templates/` 로 복사하고
`.tpl` 을 뗀다. Obsidian 을 쓰지 않는 워크스페이스면 복사를 생략하고 프리셋 폴더의
템플릿을 그때그때 참조해도 된다.

`.md.tpl` 확장자를 쓰는 이유: 템플릿의 frontmatter 는 `type: Decision` 같은 값을 갖는데
이를 `.md` 로 두면 lint 가 빈 인스턴스로 오인한다. 비-md 파일은 메타 검사 대상이
아니다(GUIDE §10 유추 기준).

팀 워크스페이스에서는 복사하는 쪽을 권장한다. 여러 사람이 각자 노트를 만들 때 프리셋
폴더까지 찾아 들어가지 않고, 안 찾으면 손으로 대충 만든다. 손으로 만든 Decision 노트는
대개 `consequences` 가 없다.

## Step 5. 루트 객체 생성

`objects/teams/<팀명>.md` 를 Team 템플릿으로 만든다. `tags: [self, root]` 를 단다.
이 노트가 모든 소유, 관행, 이니셔티브의 출발점이 된다.

루트가 사람이 아니라 팀인 것이 [[personal-rag]] 와의 근본 차이다. 특정 개인 노트에
`root` 를 달지 않는다. 그 사람이 떠나면 그래프의 뿌리가 빠진다.

`mission` 과 `chargeOf` / `notChargeOf` 는 여기서 비워 두고 다음 스텝에서 채운다.
`notChargeOf` 는 인테이크에서 가장 늦게 나오는 답이라 미리 채우려 하지 않는다.

## Step 5.5. 인테이크 (초기 문답)

[[team-ops-intake]] 의 질문지를 돌린다. 루트 Team 을 채우고 사람, 시스템,
이니셔티브, 결정, 관행, 장애, 지표의 첫 인스턴스를 만든다.

건너뛸 수 있는 스텝이지만 기본은 **돈다.** 원래 설계는 루트 하나만 만들고 GUIDE §12
능동적 축적에 맡기는 것이었는데, 축적은 대화가 일어나야 작동한다. 워크스페이스를 막
받은 팀은 아직 이 에이전트와 대화한 이력이 없어서 그 구간이 비어 있다. 인테이크는
그 부트스트랩 구간만 메우고, 그 뒤는 원래대로 축적에 맡긴다.

팀 인테이크의 고유 사정: **답하는 사람은 한 명인데 답의 주어는 팀이다.** 그 사람이
모르는 것과 팀이 합의하지 않은 것을 구분해 받아야 하고, 후자를 한 사람 답으로
확정하면 나중에 다른 구성원이 그 문장을 부정한다. 처리 규약은 전부 [[team-ops-intake]]
에 있다. 여기서 임의로 줄이지 않는다.

사용자가 "나중에"를 고르면 `memory/team-ops-intake.md` 에 전 라운드 pending 상태로
기록만 남기고 Step 6 으로 간다. 그 파일이 다음 세션의 재개 지점이 된다.

## Step 6. 프로토콜 파일 갱신

1. `_project.md`: `suitability.subjects` 에 새 개념 위키링크를 추가하고, `keywords` 에
   team ops, decision log, runbook, incident 등을 더한다. `persona.scope` 에 팀 운영
   지식그래프를 운용한다는 한 줄을 넣는다. `updated` bump.
2. `_context-protocol/_ontology.md`: 워크스페이스 레이아웃 트리에 `objects/` 이하를 반영한다.
3. `memory/MEMORY.md`: team-ops 적용 사실과 진입점(objects/team-knowledge.md)을
   인덱스 한 줄로 추가한다.
4. `action-log/<YYYY-MM-DD>.md`: 적용 사실을 엔트리로 append 한다. 형식은
   [[team-ops-actions]]. 오늘 파일이 이미 있으면 rewrite 하지 말고 append 한다.
5. `CONTEXT.md`(규칙 정본. 포털 `AGENTS.md`, `CLAUDE.md` 에는 적지 않는다): 진입점 목록에 `objects/team-knowledge.md` 를 한 줄 추가하고, 1인칭
   금지와 시점 명기 규약([[team-ops]])을 함께 적는다. CONTEXT.md 가 그 워크스페이스의
   운영 정본이고 세션이 제일 먼저 읽는 파일이다. 여기 없는 구조와 규약은 다음 세션이
   존재를 모른다. 기존 항목 번호를 재정렬하지 말고 해당 항목 본문에 덧붙이거나 끝에
   새 항목으로 붙인다.

이 다섯 가지를 같은 작업에서 처리한다. 구조를 바꿨는데 `_project.md` 를 안 고치면
cross-project import 가 이 워크스페이스를 옛 성격으로 광고한다(GUIDE §6, §12.2).

5 번의 규약을 CONTEXT.md 에 올리는 것이 팀 워크스페이스에서 특히 중요하다. 이 프리셋의
규율 규칙(1인칭 금지, 시점 명기, 소유는 팀에)은 사람이 지켜야 서고, 사람은 CONTEXT.md
바깥에 적힌 것을 읽지 않는다.

## Step 7. 검증

[[team-ops-lint]] 의 점검 목록을 돌린다. 통과 조건: 개념 12개의 broader 가 모두 실재
노트를 가리키고, DAG 이고, top concept 이 여전히 하나이고, 고아 md 가 없고, `.base`
/Dataview 산출물이 새로 생기지 않았고, action-log 에 날짜 폴더가 없고, `ownedBy` 가
사람을 가리키는 노트가 없다.

## 기존 문서 더미를 옮겨오는 경우

노션 페이지, 구글 문서, 레포의 `docs/` 가 이미 있으면 다음 순서로 번역한다. 원본을
통째로 복사하지 않는다. 이 워크스페이스는 문서 저장소가 아니라 객체 그래프다.

1. **ADR 부터 옮긴다.** `docs/adr/*.md` 는 Decision 과 1:1 대응한다. 제목을 결론
   형태로 고치고 `context` / `options` / `rationale` / `consequences` 로 재배치한다.
   대개 rationale 은 있고 consequences 가 없다. 없으면 비워 두고 lint 가 잡게 한다.
   지어내지 않는다.
2. **런북과 온보딩 문서를 Practice 로 옮긴다.** `whyItExists` 는 대개 원문에 없다.
   비워 두고 인테이크나 이후 대화에서 채운다.
3. **아키텍처 문서에서 시스템 목록을 뽑아 System 인스턴스로 만든다.** 본문을 옮기지
   말고 `purpose` 한 문단과 `dependsOn` 링크만 뽑는다. 원문은 datasource 로 가리킨다.
4. **포스트모템을 Incident 로 옮긴다.** 액션 아이템은 본문에 두지 말고 Practice,
   Decision, Initiative 로 꺼내 `triggers` 로 건다. 이것이 이 이관에서 값이 가장 큰
   작업이다. 문서 안에만 적힌 액션 아이템은 실행되지 않았을 가능성이 높고, 꺼내는
   과정에서 그 사실이 드러난다.
5. **사람 목록을 옮길 때 이탈자를 지우지 않는다.** `leftAt` 과 `kind: alumni` 로
   남긴다. 과거 Decision 의 참여자로 계속 등장해야 한다.
6. 지라와 리니어의 티켓은 옮기지 않는다. `tracker` URL 로 가리킨다.
7. 옮긴 뒤 Step 7 검증을 돌린다.
