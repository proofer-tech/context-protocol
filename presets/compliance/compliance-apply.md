---
type: document
title: compliance 적용 절차
updated: 2026-10-29
---

# 적용 절차

이 문서는 4단계 중 3단계(프리셋 얹기)다. 사용자가 "컴플라이언스 프리셋으로 ~해줘"
라고 했을 때의 전체 순서는 [[preset-library]] 의 "프리셋 호출 계약"에 있다. 프리셋
찾기(1) -> 프로토콜 설치(2) -> 이 문서(3) -> 기존 파일 정리(4). 4단계의 이동 정책도
그쪽에 있다. 여기서 다시 적지 않는다.

전제: 대상 워크스페이스에 context-protocol 이 이미 적용돼 있다(CONTEXT.md,
`_context-protocol/CONTEXT_GUIDE.md`(6.x 는 루트), memory/, action-log/, _project.md 존재). 없으면
CONTEXT_SETUP.md 로 먼저 프로토콜을 깔고 온다. 프리셋은 프로토콜 위에 얹는 레이어이고
프로토콜을 대체하지 않는다.

작업 도구는 하네스의 호스트 파일 도구다(GUIDE §5, Cowork 에서는 Desktop Commander). (proxy_mount: yes)
마운트는 삭제와 atomic-rename 을 거부하니 임시파일을 만들지 않고 rewrite/append 만 쓴다(GUIDE §4.5). 쓰기는
25~30줄 단위로 쪼갠다.

## Step 0. 사전 확인

1. `_context-protocol/_schema/concept-scheme.md` 를 읽어 top concept 이름을 확인한다. Step 2 의
   `broader` 값이 된다.
2. `_context-protocol/_ontology.md` 를 읽어 기존 개념 트리를 파악한다. `objects`, `controls`,
   `audits` 등 이름 충돌이 있는지 본다. 있으면 프리셋 폴더명을 조정하고 이 문서에
   기록한다. 감사나 보안 조직의 워크스페이스는 `audits` 나 `evidence` 를 이미 다른
   뜻으로 쓰고 있을 확률이 낮지 않다.
3. `memory/MEMORY.md` 와 `_project.md` 를 읽는다(GUIDE §6: 쓰기 전 인덱스와 대상을
   먼저 읽는다).
4. **기존 규정 문서 더미가 있는지 본다.** 이 도메인의 워크스페이스는 대개 빈 상태가
   아니라 PDF 와 워드 파일이 쌓인 상태로 온다. 있으면 마지막 절 "기존 규정 더미를
   옮겨오는 경우" 를 먼저 읽고 Step 1 로 간다.

## Step 1. 폴더 생성

```
objects/  objects/statutes/  objects/regulations/  objects/obligations/
objects/controls/  objects/evidence/  objects/audits/  objects/findings/
objects/units/
object-sets/  object-views/  datasources/
```

`evidence` 만 단수형이다([[compliance-layout]]). 오타로 `evidences` 를 만들지 않는다.

첨부 폴더를 따로 만들지 않는다. 첨부는 관련 객체와 동거한다. 증거 원본과 규정 정본은
애초에 워크스페이스에 들이지 않는 것이 기본이다([[compliance]]).

## Step 2. 개념 노트 12개 작성

각 폴더에 개념 노트를 둔다. frontmatter 형식은 대상 워크스페이스의 기존 개념 노트와
동일하게 맞춘다(`type: concept`, `scheme:`, `pref_label_ko/en`, `broader`,
`definition`).

| 파일 | 개념 id | broader |
|---|---|---|
| `objects/compliance-chain.md` | compliance-chain | WS 의 top concept |
| `objects/statutes/statute.md` | statute | compliance-chain |
| `objects/regulations/regulation.md` | regulation | compliance-chain |
| `objects/obligations/obligation.md` | obligation | compliance-chain |
| `objects/controls/control.md` | control | compliance-chain |
| `objects/evidence/evidence.md` | evidence | compliance-chain |
| `objects/audits/audit.md` | audit | compliance-chain |
| `objects/findings/finding.md` | finding | compliance-chain |
| `objects/units/unit.md` | unit | compliance-chain |
| `object-sets/object-set.md` | object-set | compliance-chain |
| `object-views/object-view.md` | object-view | compliance-chain |
| `datasources/datasource.md` | datasource | compliance-chain |

8개 타입 개념 노트의 본문에는 [[compliance-object-types]] 의 해당 절(프로퍼티 표, PK,
implements, 허용 출력 링크)을 옮긴다. 개념 노트가 곧 타입 정의를 겸한다.

**허용 출력 링크의 "비정본" 표시를 지우지 말고 그대로 옮긴다.** 표시를 지우면 설치된
워크스페이스가 규칙 11 위반을 허용으로 광고하게 된다. 그 워크스페이스를 쓰는 다음
세션은 프리셋 문서를 읽지 않고 개념 노트만 읽으므로, 표시가 없으면 정본과 비정본을
구분할 근거가 그 워크스페이스 안에 남지 않는다. 읽는 법은
[[compliance-object-types]] 의 "허용 출력 링크를 읽는 법".

`objects/compliance-chain.md` 본문에는 [[compliance]] 의 사슬 다이어그램을 옮긴다.
이 노트가 워크스페이스의 유일한 진입점이므로 사슬 모양을 여기서 한 번에 볼 수 있어야
한다.

주의: `broader` 는 개념 하나만 가리킨다. top concept 은 WS 에 정확히 하나여야 하니
`compliance-chain` 을 새 top 으로 만들지 말고 기존 top 아래에 붙인다.

## Step 3. 스킴 확장 병합

`_context-protocol/_schema/concept-scheme.md` 를 수정한다.

1. 허용 노트 타입 목록에 `Statute, Regulation, Obligation, Control, Evidence, Audit,
   Finding, Unit` 을 추가하고 "lint 상 document 로 취급, broader 없음"을 명기한다.
2. 허용 술어 표 아래에 `links` 행을 추가한다: "Link 맵. 객체 관계. 어휘는
   presets/compliance/compliance-schema.md".
3. 무결성 규칙에 규칙 7~18([[compliance-schema]])을 추가한다. 13~18 이 이 프리셋
   고유이고, 그중 일부는 데이터 오류가 아니라 실제 컴플라이언스 결함을 잡는다.
   그 성격을 스킴에도 한 줄로 적어 둔다.
4. 값 타입 Cadence 와 ComplianceStatus 를 값 타입 절에 등재한다. 코어 스킴에 값 타입
   절이 없으면 만들지 말고 술어 표 아래에 참조 한 줄만 둔다.

코어 규칙 1~6 은 건드리지 않는다.

## Step 4. 템플릿 배치

`presets/compliance/templates/*.md.tpl` 을 대상 WS 의 `_context-protocol/templates/` 로 복사하고
`.tpl` 을 뗀다. Obsidian 을 쓰지 않는 워크스페이스면 복사를 생략하고 프리셋 폴더의
템플릿을 그때그때 참조해도 된다.

`.md.tpl` 확장자를 쓰는 이유: 템플릿의 frontmatter 는 `type: Obligation` 같은 값을
갖는데 이를 `.md` 로 두면 lint 가 빈 인스턴스로 오인한다. 비-md 파일은 메타 검사
대상이 아니다(GUIDE §10 유추 기준).

## Step 5. 첫 사슬 한 줄 세우기

이 프리셋에는 루트 객체가 없다([[compliance]] "원본 대비" 1번). 대신 **Statute 하나
에서 Evidence 까지 한 갈래를 끝까지 세운다.** 폭이 아니라 깊이를 먼저 만든다.

```
Statute 1개 -> Regulation 1개 -> Obligation 1개 -> Control 1개 -> Evidence 1개
                                    + Unit 1개 (각 마디의 owner)
```

여섯 노트다. 어느 법령을 고를지는 사용자가 정하지만, 정하지 못하면 **이미 증거가 있는
것**을 고른다. 사슬 끝까지 갈 수 있는 갈래여야 이 단계의 목적이 달성된다.

이 단계를 폭 먼저로 뒤집지 않는다. 법령 스무 개를 먼저 등록하면 Statute 폴더는
그럴듯해지지만 사슬은 한 마디도 완성되지 않고, 그 상태에서는 이 워크스페이스가 답해야
하는 질문("지키고 있다는 증거가 뭐냐")에 하나도 답하지 못한다. 한 갈래가 끝까지
서 봐야 나머지 갈래에서 무엇이 비어 있는지도 보인다.

Unit 을 먼저 만들어야 나머지가 `owner` 를 채울 수 있다. 순서는 Unit -> Statute ->
Regulation -> Obligation -> Control -> Evidence 다.

여기서는 여섯 노트의 필수 프로퍼티와 사슬 링크만 채운다. 나머지 갈래는 다음 스텝에서
문답으로 채운다.

## Step 5.5. 인테이크 (초기 문답)

[[compliance-intake]] 의 질문지를 돌린다. AskUserQuestion 과 elicitation 폼으로
사용자에게 물어 사슬의 나머지 갈래와 조직 단위, 점검 이력, 열린 지적사항을 채운다.

건너뛸 수 있는 스텝이지만 기본은 **돈다.** 원래 설계는 사슬 하나만 세우고 GUIDE §12
능동적 축적에 맡기는 것이었는데, 축적은 대화가 일어나야 작동한다. 워크스페이스를 막
받은 조직은 아직 이 에이전트와 대화한 이력이 없어서 그 구간이 비어 있다. 인테이크는
그 부트스트랩 구간만 메우고, 그 뒤는 원래대로 축적에 맡긴다.

사용자가 "나중에"를 고르면 `memory/compliance-intake.md` 에 전 라운드 pending 상태로
기록만 남기고 Step 6 으로 간다. 그 파일이 다음 세션의 재개 지점이 된다.

## Step 6. 프로토콜 파일 갱신

1. `_project.md`: `suitability.subjects` 에 새 개념 위키링크를 추가하고, `keywords` 에
   컴플라이언스, 규정, 감사, 이행 증거, 내부통제 등을 더한다. `persona.scope` 에
   법령에서 증거까지의 사슬을 운용한다는 한 줄을 넣는다. `updated` bump.
2. `_context-protocol/_ontology.md`: 워크스페이스 레이아웃 트리에 `objects/` 이하를 반영한다.
3. `memory/MEMORY.md`: compliance 적용 사실과 진입점(objects/compliance-chain.md)을
   인덱스 한 줄로 추가한다.
4. `action-log/<YYYY-MM-DD>.md`: 적용 사실을 엔트리로 append 한다. 형식은
   [[compliance-actions]]. Step 5 에서 만든 여섯 노트도 createObject 로 남긴다.
5. `CONTEXT.md`(규칙 정본. 포털 `AGENTS.md`, `CLAUDE.md` 에는 적지 않는다): 진입점 목록에 `objects/compliance-chain.md` 를 한 줄 추가한다.
   CONTEXT.md 가 그 워크스페이스의 운영 정본이고 세션이 제일 먼저 읽는 파일이다. 여기
   없는 구조는 다음 세션이 존재를 모른다. 기존 항목 번호를 재정렬하지 말고 해당 항목
   본문에 덧붙이거나 끝에 새 항목으로 붙인다.

이 다섯 가지를 같은 작업에서 처리한다. 구조를 바꿨는데 `_project.md` 를 안 고치면
cross-project import 가 이 워크스페이스를 옛 성격으로 광고한다(GUIDE §6, §12.2).

## Step 7. 검증

[[compliance-lint]] 의 점검 목록을 돌린다. 통과 조건은 둘로 나뉜다.

구조: 개념 12개의 broader 가 모두 실재 노트를 가리키고, DAG 이고, top concept 이
여전히 하나이고, 고아 md 가 없고, 인스턴스에 `broader` 가 없고, 술어가 어휘 안에 있고,
action-log 에 날짜 폴더가 없다.

실질: Step 5 에서 세운 사슬이 끊긴 데 없이 Statute 부터 Evidence 까지 이어지고,
Evidence 의 기간이 Obligation 의 주기를 덮고, 모든 책임 술어가 Unit 을 가리킨다.

실질 점검이 실패하면 구조가 통과해도 적용이 끝난 것이 아니다. 이 워크스페이스의 목적이
구조가 아니라 사슬이기 때문이다.

## 기존 규정 더미를 옮겨오는 경우

공유 드라이브에 규정 PDF 와 점검 엑셀이 쌓인 상태가 흔하다. 다음 순서로 번역한다.

1. **원본을 옮기지 않는다.** 규정 정본과 증거 원본은 있던 자리에 둔다. 이 프리셋이
   만드는 것은 그것을 가리키는 노트다([[compliance]]). 파일을 워크스페이스로 복사하는
   순간 정본이 둘이 되고, 그때부터 어느 쪽이 최신인지 아무도 모른다.
2. **목록부터 만든다.** 파일 목록만 읽고 어느 것이 Regulation 이고 어느 것이 Evidence
   인지 가른다. 내용은 아직 읽지 않는다. 이 단계에서 대개 분류가 안 되는 파일이 나오고,
   그것이 새 타입 후보다([[compliance-object-types]] "8종에 없는 것이 나오면").
3. **Regulation 부터 만든다.** 규정 노트에 `location` 으로 원본 경로를 적는다.
   `location` 이 빠지면 그 노트는 요약본으로 전락한다.
4. **Obligation 을 규정에서 도출한다.** 규정 한 건에서 의무 여러 개가 나온다. 조문을
   그대로 복사하지 말고 "무엇을 언제까지 해야 하는가" 한 문장으로 줄인다.
5. **Statute 는 나중에 붙인다.** 사내 규정의 외부 근거를 역추적하는 것은 시간이 걸리고
   법무 확인이 필요하다. `basedOn` 을 비워 둔 Regulation 은 위반이 아니다. 근거가
   필수인 것은 Obligation 이다(규칙 14).
6. **점검 엑셀은 Audit + Finding 으로 푼다.** 시트 한 행이 한 Finding 인 경우가 많다.
   열린 것과 닫힌 것을 `closedAt` 으로 가른다.
7. **증거는 마지막이다.** 가장 양이 많고 가장 빨리 스테일해진다. Obligation 이 다
   서기 전에 증거를 등록하면 붙일 자리가 없다.
8. 옮긴 뒤 Step 7 검증을 돌린다. 첫 회차에는 실질 점검이 대량으로 실패하는 것이
   정상이다. 그 실패 목록이 곧 이 조직의 컴플라이언스 공백 현황이고, 그것을
   `object-views/` 에 하나 남긴다.
