---
type: document
title: 창업 적용 절차
updated: 2026-10-29
---

# 적용 절차

이 문서는 4단계 중 3단계(프리셋 얹기)다. 사용자가 "창업 프리셋으로 ~해줘" 라고 했을
때의 전체 순서는 [[preset-library]] 의 "프리셋 호출 계약"에 있다. 프리셋 찾기(1) ->
프로토콜 설치(2) -> 이 문서(3) -> 기존 파일 정리(4). 4단계의 이동 정책도 그쪽에 있다.
여기서 다시 적지 않는다.

전제: 대상 워크스페이스에 context-protocol 이 이미 적용돼 있다(CONTEXT.md,
`_context-protocol/CONTEXT_GUIDE.md`(6.x 는 루트), memory/, action-log/, _project.md 존재). 없으면
CONTEXT_SETUP.md 로 먼저 프로토콜을 깔고 온다. 프리셋은 프로토콜 위에 얹는 레이어이고
프로토콜을 대체하지 않는다.

작업 도구는 하네스의 호스트 파일 도구다(GUIDE §5, Cowork 에서는 Desktop Commander). (proxy_mount: yes)
마운트는 삭제와 atomic-rename 을 거부하니 임시파일을 만들지 않고 rewrite/append 만 쓴다(GUIDE §4.5). 쓰기는
25~30줄 단위로 쪼갠다.

창업 워크스페이스 고유 전제 하나: **대상 폴더가 창업자 개인의 현업 폴더다.** 다른 세션과
겹칠 걱정은 없는 대신 폴더에 이미 사업계획서와 신청서와 녹취가 가득하다. 그래서 3단계보다
4단계가 크고 아래 "기존 자료 더미를 옮겨오는 경우" 가 사실상 본론이다. 구조만 세우고
끝내면 빈 폴더 열두 개가 본인 자료 옆에 서 있게 된다.

## Step 0. 사전 확인

1. `_context-protocol/_schema/concept-scheme.md` 를 읽어 top concept 이름을 확인한다. Step 2 의
   `broader` 값이 된다.
2. `_context-protocol/_ontology.md` 를 읽어 기존 개념 트리를 파악하고 `객체`, `제출문서`,
   `근거` 등 이름 충돌을 본다. 있으면 프리셋 폴더명을 조정하고 이 문서에 기록한다.
3. `memory/MEMORY.md` 와 `_project.md` 를 읽는다(GUIDE §6: 쓰기 전 인덱스와 대상을
   먼저 읽는다).
4. **[[personal-rag]] 나 [[compliance]] 가 이미 얹혀 있는지 본다.** 한글화 뒤로
   **타입명 충돌은 없다.** 이쪽은 `근거` 와 `제출문서` 이고 저쪽은 `Evidence` 와
   `Artifact` 라 폴더도 개념 id 도 부딪히지 않는다.

   **그래도 실체가 가까워서 사람이 헷갈린다.** 무엇이 어떻게 다른지는 [[startup-schema]] 의
   "다른 프리셋과 실체가 겹치는 타입" 표에 있다. 그 표를 먼저 읽고 판단한다.

   두 프리셋을 한 워크스페이스에 겹치는 것은 여전히 권장하지 않는다. 그래도 해야 하면
   이름은 이미 갈라져 있으므로 바꿀 것이 없고, 대신 폴더명,
   개념 id 와 개념 노트 파일명, 타입명(술어 표의 range 포함), 템플릿 파일명 넷을
   **함께** 바꾼다. `objects/제출문서/` 를 `objects/submissions/` 로 옮기고 타입을
   `Submission` 으로 고치는 식이다. 하나라도 빠지면 같은 폴더에 두 종류가 섞여 규칙 10
   판정이 불가능해진다. 바꾼 이름은 이 워크스페이스의 `_context-protocol/_schema/concept-scheme.md` 에 기록하고,
   [[startup-lint]] 의 명령에 박힌 경로도 같이 고쳐 쓴다. 루트 마커도 정리한다.
   `tags: [self, root]` 는 이 프리셋에서 사업체 쪽 하나만 남긴다.

## Step 1. 폴더 생성

```
objects/  objects/사업체/  objects/제공물/  objects/고객군/
objects/가설/  objects/근거/  objects/마일스톤/
objects/자금/  objects/제출문서/
object-sets/  object-views/  datasources/
```

폴더명은 여덟 개 타입명 그대로 쓴다. 동의어로 바꾸면 lint 가 조용히 침묵한다([[startup-lint]]).

`첨부/` 와 `원본/` 은 만들지 않는다. 원본 파일은 그것을 대표하는 객체 옆에 둔다
([[startup-layout]]). 부속물이 쌓이는 객체의 서브폴더도 **미리 만들지 않는다.** 혼자 쓰는
폴더에 빈 서브폴더가 늘면 본인이 헷갈린다. 부속물이 둘 이상 생긴 뒤에 만든다.

## Step 2. 개념 노트 12개 작성

각 폴더에 개념 노트를 둔다. frontmatter 형식은 대상 워크스페이스의 기존 개념 노트와
동일하게 맞춘다(`type: concept`, `scheme:`, `pref_label_ko/en`, `broader`,
`definition`).

| 파일 | 개념 id | broader |
|---|---|---|
| `objects/venture-knowledge.md` | venture-knowledge | WS 의 top concept |
| `objects/사업체/사업체.md` | 사업체 | venture-knowledge |
| `objects/제공물/제공물.md` | 제공물 | venture-knowledge |
| `objects/고객군/고객군.md` | 고객군 | venture-knowledge |
| `objects/가설/가설.md` | 가설 | venture-knowledge |
| `objects/근거/근거.md` | 근거 | venture-knowledge |
| `objects/마일스톤/마일스톤.md` | 마일스톤 | venture-knowledge |
| `objects/자금/자금.md` | 자금 | venture-knowledge |
| `objects/제출문서/제출문서.md` | 제출문서 | venture-knowledge |
| `object-sets/object-set.md` | object-sets | venture-knowledge |
| `object-views/object-view.md` | object-views | venture-knowledge |
| `datasources/datasource.md` | 출처 | venture-knowledge |

8개 타입 개념 노트의 본문에는 [[startup-object-types]] 의 해당 절(프로퍼티 표, PK,
implements, 허용 출력 링크)을 옮긴다. 개념 노트가 곧 타입 정의를 겸한다.

**허용 출력 링크의 "비정본" 표시를 지우지 말고 그대로 옮긴다.** 그 줄이 없으면 다음에
읽는 사람이 역방향 술어를 정본으로 읽고 양쪽에 적어서 규칙 11 위반을 만든다. 이 프리셋은
정본이 전부 나중에 생기는 쪽이라 직관과 어긋나는 자리가 많다. 근거가 가설을 가리키고 문서가
주장을 가리킨다. 요약표는 [[startup-schema]] 규칙 11 아래에 있다.

주의: `broader` 는 개념 하나만 가리킨다. top concept 은 WS 에 하나여야 하니
`venture-knowledge` 를 새 top 으로 만들지 말고 기존 top 아래에 붙인다.

## Step 3. 스킴 확장 병합

`_context-protocol/_schema/concept-scheme.md` 를 수정한다.

1. 허용 노트 타입 목록에 `사업체, 제공물, 고객군, 가설, 근거, 마일스톤,
   자금, 제출문서` 를 추가하고 "lint 상 document 로 취급, broader 없음"을 명기한다.
2. 허용 술어 표 아래에 `links` 행을 추가한다: "Link 맵. 객체 관계. 어휘는
   presets/startup/startup-schema.md".
3. 무결성 규칙에 규칙 7~18([[startup-schema]])을 추가한다. **16 과 17 은 구조 검사가
   아니라 규율 검사임을 함께 적는다.** 적지 않으면 다음 사람이 "자동으로 못 잡으니 빼자"
   고 판단한다. 이 프리셋이 실패하는 방식이 정확히 그 둘이다. 출처 없는 숫자와 반증 뒤에도
   살아남는 전제는 스키마 위반 없이 조용히 쌓인다.

코어 규칙 1~6 은 건드리지 않는다.

## Step 4. 템플릿 배치

`presets/startup/templates/*.md.tpl` 을 대상 WS 의 `_context-protocol/templates/` 로 복사하고
`.tpl` 을 뗀다.

`.md.tpl` 확장자를 쓰는 이유: 템플릿의 frontmatter 는 `type: 가설` 같은 값을 갖는데
이를 `.md` 로 두면 lint 가 빈 인스턴스로 오인한다. `falsifiable` 이 비어 있으니 규칙 13
위반으로도 잡힌다. 비-md 파일은 메타 검사 대상이 아니다(GUIDE §10 유추 기준).

**창업 워크스페이스에서는 복사하는 쪽을 권장하지 않는다.** [[team-ops]] 와 갈리는
자리다. 팀에서는 여러 사람이 각자 노트를 만들어서 템플릿이 손에 닿는 곳에 있어야 했다.
여기는 만드는 사람이 하나이고, 대개 에이전트가 대신 만든다. 혼자 쓰는 폴더에 파일 여덟
개가 느는 것이 그 자체로 부담이라 프리셋 폴더의 템플릿을 그때그때 참조하는 편이 낫다.

예외: Obsidian 을 쓰면 복사한다. 템플릿 플러그인이 볼트 안의 파일만 읽는다.

## Step 5. 루트 사업체 생성

`objects/사업체/<사업체명>.md` 를 사업체 템플릿으로 만들고 `tags: [self, root]` 를 단다.
이 노트가 모든 소유와 주장과 자금의 출발점이 된다.

법인 설립 전이면 팀명이나 서비스명을 PK 로 쓴다. **`legalEntity` 는 비워 두는 것이
정상이다.** 없다는 사실 자체가 지원사업 자격 판정의 입력이므로 "설립 예정" 같은 값으로
채우지 않는다. 예정은 마일스톤 이다.

`oneLiner` 를 사업계획서 첫 문장에서 베끼지 않는다. 그 문장은 심사용으로 다듬은 것이라
형용사가 많고, 여기는 조회의 앵커라서 짧고 사실적인 편이 낫다. `stage` 는 지금 상태로
고른다. 바라는 상태로 고르면 이 워크스페이스의 첫 필드부터 주장이 된다. `problem` 과
`team` 은 여기서 한 줄만 적고 다음 스텝에서 다듬는다.

## Step 5.5. 인테이크 (초기 문답)

[[startup-intake]] 의 질문지를 돌린다. 루트 사업체 를 채우고 제품, 고객군, 가설, 근거,
마일스톤, 지원사업, 자료의 첫 인스턴스를 만든다.

건너뛸 수 있는 스텝이지만 기본은 **돈다.** 원래 설계는 루트 하나만 만들고 GUIDE §12 능동적
축적에 맡기는 것이었는데, 축적은 대화가 일어나야 작동한다. 워크스페이스를 막 받은 창업자
에게는 그 대화 이력이 없다. 인테이크는 그 부트스트랩 구간만 메우고 뒤는 축적에 맡긴다.

창업 인테이크의 고유 사정: **답의 대부분이 가설이다.** 시장 규모도 고객 반응도 가격도 아직
추정인데 사업계획서를 여러 번 쓴 사람일수록 그것을 사실처럼 말한다. 그 문장을 프로퍼티로
확정하면 이 프리셋이 하려는 분리가 첫 세션에서 무너진다. 무엇을 가설 로 받고 무엇을
프로퍼티로 받는지는 [[startup-intake]] 에 있고 여기서 임의로 줄이지 않는다.

사용자가 "나중에" 를 고르면 `memory/startup-intake.md` 에 전 라운드 pending 상태로
기록만 남기고 Step 6 으로 간다. 그 파일이 다음 세션의 재개 지점이 된다.

## Step 6. 프로토콜 파일 갱신

1. `_project.md`: `suitability.subjects` 에 새 개념 위키링크를 추가하고, `keywords` 에
   창업, 가설 검증, 사업계획서, 지원사업, IR 등을 더한다. `persona.scope` 에 검증 상태가
   드러나는 사업 지식그래프를 운용한다는 한 줄을 넣는다. `updated` bump.
2. `_context-protocol/_ontology.md`: 워크스페이스 레이아웃 트리에 `objects/` 이하를 반영한다.
3. `memory/MEMORY.md`: 창업 적용 사실과 진입점(objects/venture-knowledge.md)을
   인덱스 한 줄로 추가한다.
4. `action-log/<YYYY-MM-DD>.md`: 적용 사실을 엔트리로 append 한다. 형식은
   [[startup-actions]]. 오늘 파일이 이미 있으면 rewrite 하지 말고 append 한다.
5. `CONTEXT.md`(규칙 정본. 포털 `AGENTS.md`, `CLAUDE.md` 에는 적지 않는다): 진입점 목록에 `objects/venture-knowledge.md` 를 한 줄 추가하고, **[[startup-lookup]]
   의 조회 규칙 절과 디스크립터 규칙을 그 문서에 적힌 대로 옮긴 뒤**, 이 프리셋의
   규율 규약을 함께 적는다. 반증 조건 없는 가설을 만들지 않는다, 숫자에는 출처를 붙인다,
   문서 제출 전에 미검증 주장을 보고한다. CONTEXT.md 가 그 워크스페이스의 운영 정본이고
   세션이 제일 먼저 읽는 파일이라, 여기 없는 구조와 규약은 다음 세션이 존재를 모른다. 기존
   항목 번호를 재정렬하지 말고 해당 항목에 덧붙이거나 끝에 새 항목으로 붙인다.

이 다섯 가지를 같은 작업에서 처리한다. 구조를 바꿨는데 `_project.md` 를 안 고치면
cross-project import 가 이 워크스페이스를 옛 성격으로 광고한다(GUIDE §6, §12.2). 5 번이
특히 중요하다. 규율 규칙 셋은 자동으로 서지 않고 매 세션 지켜져야 하는데, 세션은 CONTEXT.md
바깥에 적힌 것을 읽지 않는다.

## Step 7. 검증

[[startup-lint]] 의 점검 목록을 돌린다. 통과 조건: 개념 12개의 broader 가 모두 실재 노트를
가리키고, DAG 이고, top concept 이 여전히 하나이고, 고아 md 가 없고, `.base`/Dataview
산출물이 새로 생기지 않았고, action-log 에 날짜 폴더가 없고, `ownedBy` 가 사업체 를 벗어난
노트가 없고, `falsifiable` 이 빈 가설 와 `sampleSize` 가 빈 근거 가 없다.

적용 직후에는 인스턴스가 적어 전부 통과하는 것이 정상이다. 이 목록의 값은 반년 뒤에
같은 명령을 다시 돌릴 때 나온다.

## 기존 자료 더미를 옮겨오는 경우

사업계획서 폴더, 지원사업 폴더, 고객 인터뷰 기록이 이미 있으면 다음 순서로 번역한다.
**원본 폴더를 남기고 그 위에 객체 층을 얹는다**([[startup-layout]]). 원본을 통째로
`objects/` 로 옮기면 적용 직후 본인이 자기 자료를 못 찾는다. 이 워크스페이스는 문서 저장소가
아니라 객체 그래프라서 문서는 원래 자리에 둬도 된다.

1. **사업계획서 최신판부터 제출문서 로 올리고, 그 안의 주장을 가설 로 꺼낸다.**
   본문을 옮기지 말고 `version`, `kind`, `status`, `sourceFile` 만 채운 뒤 문서를 읽으며
   단정문을 골라내고, 고른 문장마다 `falsifiable` 을 물어 채워 `claims` 로 건다. **이
   작업이 이관에서 값이 가장 크다.** 꺼내는 과정에서 근거 없는 주장이 드러나고 그 목록은
   대개 본인 예상보다 길다. 반증 조건을 못 적겠는 문장은 문서 안의 수사로 남겨 둔다.
2. **지원사업 폴더를 자금 으로 옮긴다.** 공고 하나에 인스턴스 하나다. `eligibility` 는
   판정에 쓰이는 조건만 옮긴다. 창업 3년 이내, 대표 연령, 소재지, 중복 수혜 제한, 업종 제한.
   공고 본문은 복사하지 않는다. 떨어진 공고도 `status: rejected` 로 남긴다. 이듬해 같은
   조건으로 다시 나온다.
3. **인터뷰와 설문 기록을 근거 로 옮긴다.** `finding` 에 해석을 섞지 말고 관측만 적는다.
   **`sampleSize` 를 못 찾으면 비우고 lint 가 잡게 한다. 지어내지 않는다.** 몇 명을
   만났는지 기억나지 않는 기록은 그 사실 자체가 정보다. 옮기면서 그 관측이 1 단계에서 나온
   가설 중 무엇에 닿는지 `supports` 또는 `refutes` 로 건다.
4. **제품 설명을 제공물 으로 옮긴다.** `valueProp` 만 뽑고 기능 목록은 원본에 둔다.
   그 제품이 딛고 선 전제를 1 단계의 가설에서 찾아 `assumes` 로 건다. 이 링크가 나중에
   피봇 판정의 입력이 된다.
5. **옛 판 문서를 지우지 않는다.** 판이 여러 벌이면 각각 제출문서 로 올리고 새 판에
   `supersedes` 를 걸어 잇는다. 옛 판은 `status: superseded` 로 두고, 어느 시점에 무엇을
   주장했는지가 재신청과 중복 수혜 판정의 근거가 된다.
6. **이동은 승인받고 한다.** 여기까지는 전부 생성이라 승인이 필요 없다. 원본 파일을 객체
   옆으로 옮기기로 했으면 "이 파일 -> 이 위치" 매핑표를 근거 한 줄씩 붙여 제시하고, 승인받은
   것만 호스트 파일 도구(Cowork 에서는 Desktop Commander `move_file`)로 옮긴 뒤 `sourceFile` 과 상대링크를 고치고
   action-log 에 남긴다. 상세 정책은 [[preset-library]].
7. 옮긴 뒤 Step 7 검증을 돌린다.
