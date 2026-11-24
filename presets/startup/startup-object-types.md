---
type: document
title: 창업 객체 타입 8종
updated: 2026-09-16
---

# 객체 타입 8종

각 타입은 대상 워크스페이스에서 `objects/<folder>/<concept-id>.md` 개념 노트가 된다.
그 노트의 frontmatter 는 개념 노트 규약을 따르고, 본문에 여기 적힌 타입 정의(프로퍼티
표, PK, 인터페이스, 허용 출력 링크)를 옮긴다. 개념 노트가 스키마이고 같은 폴더의 나머지
md 가 인스턴스다.

인스턴스 frontmatter 는 `type: <ObjectType>` 을 그대로 쓴다. 이 8개 값은 프리셋 스킴
확장이 허용 노트 타입으로 등재하며 lint 상 document 로 취급된다([[startup-schema]]).

| 타입 | 폴더 | 개념 id | PK | 구현 인터페이스 |
|---|---|---|---|---|
| 사업체 | `objects/사업체/` | 사업체 | slug | HasIdentity, Temporal |
| 제공물 | `objects/제공물/` | 제공물 | slug | HasIdentity, Owned |
| 고객군 | `objects/고객군/` | 고객군 | slug | HasIdentity, Owned |
| 가설 | `objects/가설/` | 가설 | slug | HasIdentity, Temporal, Owned, Falsifiable |
| 근거 | `objects/근거/` | 근거 | slug | HasIdentity, Temporal, Owned, Sourced |
| 마일스톤 | `objects/마일스톤/` | 마일스톤 | slug | HasIdentity, Temporal, Owned |
| 자금 | `objects/자금/` | 자금 | slug | HasIdentity, Temporal, Owned |
| 제출문서 | `objects/제출문서/` | 제출문서 | slug | HasIdentity, Temporal, Owned, Sourced |

PK 는 파일명이다. WS 안에서 유일해야 하고 한글도 된다. 여덟 타입 모두 `slug` PK 다.
사람 이름을 PK 로 쓰는 타입은 이 프리셋에 없다. 이유는 맨 아래 워크드 예시에 있다.

폴더명이 전부 한글이라 **단복수 문제가 없다.** 영문 타입명을 쓰던 때는 `evidence` 만
복수형이 같아서 폴더명 하나가 단수로 서 있었고, 그것을 복수로 고치면 lint 가 조용히
침묵하는 함정이 있었다. 한글에서는 그 자리가 사라졌다.

## 허용 출력 링크를 읽는 법

각 타입 절 끝의 "허용 출력 링크" 는 그 타입의 인스턴스가 **직접 걸 수 있는** 술어다.
정본 방향이 반대편에 있는 술어는 "비정본" 으로 따로 표시했다. 비정본 술어는 어휘에는
있으나 그 노트에 적는 것이 기본이 아니고, 반대편 노트에 이미 적혀 있으면 여기 또 적으면
규칙 11 위반이다([[startup-schema]]).

**이 프리셋의 정본 방향은 대부분 "나중에 생기는 쪽" 이다.** 가설은 먼저 서고 근거는
나중에 붙으므로 근거 쪽이 정본이다. 제품은 먼저 서고 문서는 나중에 나오므로 문서 쪽이
정본이다. 새 사실이 생길 때 파일 하나만 건드리게 하는 방향이다.

[[startup-apply]] Step 2 가 이 목록을 대상 워크스페이스의 개념 노트 본문으로 옮긴다.
**옮길 때 비정본 줄을 그대로 가져가되 표시를 지우지 않는다.**

## 사업체

루트 객체. 이 워크스페이스가 담는 사업체다. WS 하나에 인스턴스 하나가 원칙이다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `name` | string | O | 사업체명. 법인 설립 전이면 팀명이나 서비스명 |
| `oneLiner` | string | O | 한 문장으로 무엇을 하는 사업인가 |
| `stage` | enum | O | idea / prototype / preRevenue / earlyRevenue |
| `problem` | text | O | 누구의 무슨 문제를 다루는가 |
| `foundedAt` | date |  | 창업일 또는 팀 결성일 |
| `legalEntity` | string |  | 법인명과 설립일. 설립 전이면 비움 |
| `team` | text |  | 현재 팀 구성. 누가 무엇을 맡는가 |
| `industry` | string |  | 업종 |
| `location` | string |  | 소재지. 지역 제한이 붙는 지원사업 판정에 쓰인다 |

허용 출력 링크: 없음. 루트는 나가는 링크를 갖지 않는다.
비정본: offers -> 제공물, pursues -> 마일스톤, holds -> 가설
(셋 다 정본은 각 객체 쪽 ownedBy)

**`legalEntity` 를 비워 두는 것이 정상 상태다.** 예비창업자는 법인이 없고, 없다는 사실
자체가 지원사업 자격 판정의 입력이다. 없는 것을 "설립 예정" 으로 채우지 않는다. 예정은
마일스톤 이다.

**`oneLiner` 를 만들 때 문서에서 베끼지 않는다.** 사업계획서 첫 문장은 심사용으로 다듬은
문장이라 대개 형용사가 많다. 여기는 조회의 앵커라서 짧고 사실적인 편이 낫다.

루트 사업체 인스턴스에 `tags: [self, root]` 를 단다.

## 제공물

파는 것. 제품, 서비스, 콘텐츠, 플랫폼. 아직 안 만든 것도 개념 단계로 등록한다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 이름 |
| `kind` | enum | O | product / service / content / platform |
| `status` | enum | O | concept / prototype / beta / live / retired |
| `valueProp` | text | O | 이것을 쓰면 무엇이 달라지는가 |
| `pricing` | string |  | 과금 형태와 값. 미정이면 비움 |
| `launchedAt` | date |  | 출시 |
| `retiredAt` | date |  | 중단 (비움 = 살아 있음) |

허용 출력 링크: ownedBy -> 사업체, targets -> 고객군, assumes -> 가설,
supersedes -> 제공물
비정본: supersededBy -> 제공물 (정본은 새 제공물 쪽 supersedes. 옛 노트는 status 만
바꾼다)

**`assumes` 가 이 타입에서 가장 값이 크다.** 제품은 항상 몇 개의 믿음 위에 서 있다.
그 믿음을 여기 걸어 두면, 믿음이 반증됐을 때 무엇이 함께 무너지는지가 한 번의 읽기로
나온다. 걸어 두지 않으면 반증이 가설 폴더 안에서만 일어나고 제품은 그대로 살아 있다.

`status: retired` 를 지우지 않는다. **접은 제품이 가장 자주 다시 제안된다.** 왜 접었는지는
대개 반증된 가설에 적혀 있으므로 `assumes` 링크를 남긴 채로 둔다.

피봇으로 제품이 갈리면 새 제공물 을 만들고 `supersedes` 로 잇는다. 옛 노트를 고쳐
쓰지 않는다.

## 고객군

파는 대상. 개별 고객사가 아니라 **고객군**이다. 한 곳뿐이어도 군으로 적는다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 이 고객군을 부르는 이름 |
| `who` | text | O | 누구인가. 업종, 규모, 의사결정 역할 |
| `jobToBeDone` | text | O | 그들이 해결하려는 것. 우리 제품 말고 그들의 목적 |
| `size` | string |  | 추정 규모. **출처를 함께 적는다** |
| `reachability` | text |  | 어떻게 닿는가. 실제로 닿아 본 경로 |
| `status` | enum |  | target / tested / parked |

허용 출력 링크: ownedBy -> 사업체, assumes -> 가설.
비정본: servedBy -> 제공물 (정본은 제공물 쪽 targets)

**`jobToBeDone` 을 우리 제품 설명으로 채우지 않는다.** "우리 솔루션으로 재고를
관리한다" 가 아니라 "재고를 덜 쌓고도 품절을 안 내려 한다" 다. 앞 문장으로 적으면 이
고객군이 우리 없이 지금 무엇으로 그 일을 하고 있는지가 사라지고, 경쟁 인식이 통째로
빠진다.

**`size` 는 규칙 16 이 가장 자주 잡는 자리다.** 시장 규모 숫자는 문서 사이를 옮겨
다니며 출처를 잃는다. 출처를 못 적겠으면 숫자를 비우고 가설 로 올린다. 추정은
주장이다.

`status: parked` 는 검토했다가 접은 고객군이다. 지우지 않는다. 접은 이유가 다음 피봇
논의의 입력이다.

## 가설

아직 확인되지 않은 주장. **이 프리셋의 중심 타입이다.**

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 주장을 평서문으로. 의문문이나 명사구로 적지 않는다 |
| `about` | enum | O | problem / customer / solution / channel / pricing / market / team |
| `status` | enum | O | unvalidated / testing / validated / invalidated / retired |
| `statedAt` | date | O | 이 주장을 처음 적은 시점 |
| `falsifiable` | text | O | **무엇이 관측되면 이 주장이 틀린 것인가** |
| `confidence` | enum |  | hunch / indicative / strong |
| `settledAt` | date |  | validated 또는 invalidated 가 된 시점 |

허용 출력 링크: ownedBy -> 사업체.
비정본: supportedBy / refutedBy -> 근거 (정본은 근거 쪽 supports / refutes),
claimedIn -> 제출문서 (정본은 제출문서 쪽 claims),
testedBy -> 마일스톤 (정본은 마일스톤 쪽 tests)

**`title` 에 주장을 적는다.** "고객 가격 민감도" 가 아니라 "이 고객군은 가격보다 도입
기간에 민감하다" 다. 명사구로 적으면 무엇을 믿고 있는지가 사라지고, 사라지면 반증할
수도 없다.

**`falsifiable` 을 비우지 않는다(규칙 13).** 반증 조건이 없는 문장은 가설이 아니라
구호다. "시장이 크다" 는 무엇을 관측해도 틀리지 않으므로 이 워크스페이스에 들어올 수
없다. "이 고객군의 연간 구매액이 평균 500만원 미만이면 틀린 것" 으로 적어야 한다.
못 적겠으면 그 문장은 가설이 아니고, 그러면 사업계획서 수사로 남겨 둔다.

**`confidence` 는 근거의 세기이지 내 확신이 아니다.** hunch 는 근거 없음, indicative 는
소수 관측, strong 은 반복 관측이다. [[team-ops-schema]] 가 이 축을 버린 것과 반대로
여기서는 살려 둔다. 팀 운영 사실은 팀이 정한 것이라 신뢰도 축이 의미가 없지만, 창업
가설은 정의상 전부 추정이라 세기를 구분하지 않으면 전부 같은 무게로 읽힌다.

`status: invalidated` 를 지우지 않는다. 반증된 가설이 이 워크스페이스에서 가장 비싼
자산이다. 무엇을 시도했고 왜 접었는지가 사라지면 같은 방향이 반년마다 돌아온다.

`retired` 는 반증된 것이 아니라 **더는 중요하지 않아진** 주장이다. 사업이 바뀌어 그
질문 자체가 무의미해진 경우다. invalidated 와 섞지 않는다. 전자는 틀린 것이고 후자는
안 묻게 된 것이다.

## 근거

관측된 것. 인터뷰, 설문, 실험, 사용 기록, 실제 매출, 2차 자료, 전문가 의견.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 관측했는가 |
| `kind` | enum | O | interview / survey / experiment / usage / sale / desk / expert |
| `collectedAt` | date | O | 관측 시점 |
| `sampleSize` | string | O | 규모. `n=3`, `매출 2건`, `공고 82건` 처럼 세는 단위까지 |
| `finding` | text | O | 무엇이 관측됐는가. 해석 말고 관측 |
| `method` | text |  | 어떻게 모았는가 |
| `source` | string |  | 2차 자료면 출처 URL 또는 문헌 |

허용 출력 링크: supports -> 가설, refutes -> 가설, ownedBy -> 사업체,
aboutSegment -> 고객군

**`sampleSize` 가 이 타입의 존재 이유다(규칙 15).** "고객 인터뷰에서 확인했다" 는
3건인지 30건인지에 따라 전혀 다른 문장이고, 읽는 사람은 대개 큰 쪽으로 읽는다. 투자
실사와 지원사업 대면평가에서 반드시 나오는 질문이 이것이다.

**`finding` 에 해석을 섞지 않는다.** "가격에 민감하지 않았다" 는 해석이고 "다섯 곳 중
네 곳이 가격을 먼저 묻지 않고 도입 기간을 먼저 물었다" 가 관측이다. 해석은 가설 쪽에
있고, 해석과 관측을 같은 칸에 적으면 이 프리셋이 하려는 분리가 그 자리에서 무너진다.

**한 근거 가 여러 가설을 건드리는 것은 정상이다.** 인터뷰 한 건이 가격 가설을
지지하면서 채널 가설을 반증할 수 있다. `supports` 와 `refutes` 를 동시에 갖는 노트가
나오면 그것은 잘 쓴 노트다.

`kind: desk` 는 남이 만든 자료다. 통계청, 연구보고서, 기사. `source` 를 비우면 안 된다.
`kind: expert` 는 전문가 의견이고 그것도 관측이 아니라 진술이라 `sampleSize` 가 1 이다.
1 이라고 적는 것이 이 타입의 규율이다.

짧아도 된다. 날짜, 대상, 규모, 들은 것 네 줄이면 성립한다. 길이가 아니라 존재가 값이다.

## 마일스톤

우리가 하기로 한 일. 시작과 끝이 있다.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 무엇을 하는가 |
| `status` | enum | O | planned / active / done / missed / dropped |
| `definitionOfDone` | text | O | 무엇이 되면 끝난 것인가 |
| `startDate` | date |  | 시작 |
| `dueDate` | date |  | 목표 시점 |
| `doneAt` | date |  | 실제 완료 |
| `outcome` | text |  | 실제로 무엇이 달라졌나 |

허용 출력 링크: ownedBy -> 사업체, tests -> 가설,
delivers -> 제공물 / 제출문서, fundedBy -> 자금

**마일스톤은 틀리지 않는다.** 하거나 못 할 뿐이다. 틀릴 수 있는 문장은 가설 다.
둘을 가르는 기준과 그것을 합쳤을 때 생기는 착각은 [[startup]] 에 있다.

**`tests` 를 걸어 둔 마일스톤이 이 타입의 값이다.** "파일럿 다섯 곳" 은 그 자체로는
일정이고, 어느 가설을 시험하려고 하는지가 붙어야 결과를 읽을 수 있다. 다섯 곳을
붙였는데 아무도 재계약하지 않으면 `status: done` 이면서 그 가설은 `invalidated` 다.
이 조합이 표현되는 것이 설계 목적이다.

`status: missed` 와 `dropped` 를 구분한다. 전자는 하려다 못 한 것이고 후자는 안 하기로
한 것이다. 반년 뒤에 읽는 사람에게 뜻이 완전히 다르다.

`outcome` 없이 닫지 않는다. 특히 `dropped` 가 그렇다.

## 자금

돈이 들어오는 트랙. 지원사업, 투자, 대출, 상금, 그리고 매출.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 공고명 또는 라운드명 |
| `kind` | enum | O | grant / program / investment / loan / prize / revenue |
| `status` | enum | O | watching / preparing / applied / selected / rejected / contracted / closed |
| `provider` | string | O | 주관기관, 투자사, 고객사 |
| `amount` | string |  | 금액과 단위. 지원금이면 자부담 비율까지 |
| `announcedAt` | date |  | 공고일 |
| `deadline` | date |  | 접수 마감 |
| `decidedAt` | date |  | 선정 또는 탈락 통보 |
| `eligibility` | text |  | 자격요건 요지. **공고 원문 기준** |
| `useOfFunds` | text |  | 쓸 곳. 집행 제한이 있으면 함께 |

허용 출력 링크: ownedBy -> 사업체, requires -> 제출문서, assumes -> 가설.
비정본: funds -> 마일스톤 (정본은 마일스톤 쪽 fundedBy)

**`eligibility` 를 요약하지 말고 판정에 쓰이는 조건만 옮긴다.** 창업 3년 이내, 대표
연령, 소재지, 중복 수혜 제한, 업종 제한. 이 다섯이 실제로 떨어뜨리는 조건이고 나머지는
읽을 필요가 없다. 원문 링크는 `sources` 에 둔다. **공고 본문을 복사하지 않는다.**
공고는 개정되고 복사본은 그 사실을 모른다.

`status: rejected` 를 지우지 않는다. 탈락한 공고가 이듬해 같은 조건으로 다시 나온다.
그때 필요한 것이 작년에 무엇을 냈고 왜 떨어졌는지다.

`kind: revenue` 를 여기 두는 이유는 초기 창업에서 첫 매출이 자금 조달과 같은 자리에
서기 때문이다. 다만 매출이 반복되기 시작하면 이 타입에서 세지 않는다. 그때는 이
프리셋을 벗을 시점에 가깝다([[startup]]).

## 제출문서

만들어 낸 자료. 사업계획서, 신청서, IR 덱, 소개서, 스펙, 보고서, 계약서.

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `slug` | string | O | 식별자 (PK) |
| `title` | string | O | 자료명 |
| `kind` | enum | O | plan / application / deck / onepager / spec / report / contract |
| `version` | string | O | 판본. 같은 문서가 여러 벌이므로 필수다 |
| `status` | enum | O | draft / final / submitted / superseded |
| `authoredAt` | date |  | 작성 시점 |
| `submittedTo` | string |  | 제출처 |
| `submittedAt` | date |  | 제출일 |
| `sourceFile` | string |  | 원본 파일 상대경로 |

허용 출력 링크: ownedBy -> 사업체, claims -> 가설, cites -> 근거,
describes -> 제공물 / 고객군, supersedes -> 제출문서.
비정본: supersededBy -> 제출문서 (새 판 쪽 supersedes 가 정본. 옛 판은 status 만 바꾼다)

**`claims` 가 이 프리셋 전체의 핵심 술어다.** 제출문서 는 본문을 담지 않는다. 그 문서가
무엇을 주장했는지만 가설로 꺼내 여기 건다. 그렇게 해 두면 "이 신청서에 들어간 주장 중
아직 근거가 없는 것" 이 한 번의 조회로 나온다. 제출 전에 이 조회를 돌리는 것이 이
워크스페이스를 쓰는 가장 큰 이유다.

**본문을 옮기지 않는 이유는 분량이 아니라 성격이다.** 제출용 문서는 심사자를 설득하려고
쓴 글이고, 설득용 문장은 확신의 정도를 지운다. 그 문장을 워크스페이스에 옮기면 과장이
사실로 승격되고, 다음에 AI 가 그 문장을 근거로 읽는다.

**`version` 이 필수인 이유는 창업 자료의 기본 상태가 여러 벌이기 때문이다.** 지원사업마다
분량과 양식이 달라 사업계획서를 매번 다시 쓴다. 파일명만으로는 어느 것이 최신인지 모르고,
`최종_진짜최종` 같은 이름이 그 실패의 흔적이다. 옛 판은 지우지 않고 `status: superseded`
로 두고 새 판에서 `supersedes` 로 잇는다.

`submittedTo` 가 있으면 `submittedAt` 도 있어야 한다(규칙 18). 어디에 언제 냈는지가
같이 있어야 중복 수혜 판정과 재신청 판정이 선다.

## 8종에 없는 것이 나오면 타입을 만든다

핵심 8종은 출발점이다. 울타리로 읽으면 안 된다. 어떤 대상이 8종 중 어디에도 정확히
맞지 않으면 가장 가까운 타입에 밀어넣지 말고 **새 타입 폴더를 만든다**. 판단 순서는
프로토콜과 같다. 정확히 맞는 기존 타입 -> 기존 타입의 특수화 -> 새 타입 폴더 -> 폴더를
가질 만큼 인스턴스가 없으면 추상 개념.

억지 분류의 신호: "근거 는 아니지만 근거 폴더에", "마일스톤 으로 치자",
"kind 를 하나 늘려서".

### 워크드 예시: 사람을 어디에 둘까

공동창업자, 멘토, 심사위원, 첫 직원을 넣으려 한다. 8종을 훑으면 어디에도 맞지 않는다.

- 사업체: 아니다. `team` 프로퍼티가 있지만 그것은 구성을 한 문단으로 적는 칸이고
  개별 인물의 이력과 관계를 담지 못한다
- 고객군: 아니다. 고객군이고 우리 쪽 사람이 아니다
- 근거: 아니다. 멘토 의견은 근거 이지만 멘토 자신은 그 의견이 아니다

**그런데 이 프리셋은 Person 을 일부러 8종에 넣지 않았다.** 창업 초기의 사람은 대부분
사업체 의 `team` 한 문단으로 충분하고, 인물 노트가 실제로 필요해지는 시점은 사람이
여럿이 되어 사실이 사람에게 귀속되기 시작하는 때다. 그 시점은 [[team-ops]] 로 옮길
시점과 거의 겹친다. 미리 넣어두면 인스턴스 서너 개짜리 폴더가 반년을 빈 채로 선다.

그래서 **필요해진 뒤에 만든다.** 만들 때는 이렇게 한다. `Person`, 폴더
`objects/people/`, 개념 id `person`, broader `venture-knowledge`.

```yaml
# objects/people/person.md 의 타입 정의 (개념 노트 본문)
type: Person
plural: People
primaryKey: name
implements: [HasIdentity]
```

| 프로퍼티 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `name` | string | O | 이름 (PK) |
| `kind` | enum | O | founder / employee / advisor / investor / reviewer |
| `role` | string |  | 맡은 것 |
| `joinedAt` | date |  | 합류 |
| `leftAt` | date |  | 이탈 |
| `background` | text |  | 이 사업과 관련된 이력만 |

허용 출력 링크: `ownedBy` -> 사업체, 그리고 **새로 등재해야 하는 술어 둘**
`coFounds` -> 사업체, `advises` -> 사업체 / 제공물.

뒤의 둘은 [[startup-schema]] 술어 표에 아직 없다. 이 예시를 그대로 쓰려면 타입 폴더를
만들기 전에 표에 두 행을 먼저 추가해야 한다(스키마 우선 원칙). 등재하지 않고 쓰면
규칙 10 위반이다.

`background` 를 이력서로 채우지 않는 것이 요점이다. **이 사업과 관련된 이력만 적는다.**
지원사업 신청서의 팀 항목에 들어갈 문장이 목표이고, 그 문장은 전체 경력이 아니라 이
사업을 왜 이 사람이 하는지를 답한다.

[[personal-rag]] 와 [[team-ops]] 둘 다 Person 타입을 갖고 있고 프로퍼티 표가 서로 다르다.
셋을 한 워크스페이스에 얹지 않는다. 충돌 상세는 [[startup-schema]].

## 타입 추가: 프리셋 고유 델타

절차의 정본은 프로토콜이다. `_context-protocol/_ontology.md` 의 "둘 곳이 없으면 만든다" 와 "어휘를
늘릴 때" 를 따른다. 여기 다시 적지 않는다.

이 프리셋에서만 추가로 지켜야 하는 것:

1. 인스턴스 폴더는 `objects/<타입명>/` 아래에 두고 개념 노트는 그 안에 같은 이름으로 둔다.
   폴더명과 개념 id 와 타입명이 한 글자도 다르지 않아야 한다. `broader` 는
   `[[venture-knowledge]]`.
2. 개념 노트 본문에 프로퍼티 표, PK, `implements`, 허용 출력 링크를 적는다.
3. 새 술어는 [[startup-schema]] 의 술어 표에 행을 추가한다.
4. **새 타입이 주장과 근거의 분리를 흐리지 않는지 확인한다.** 어떤 타입이 "우리가 믿는
   것" 과 "관측된 것" 을 같은 칸에 담게 되면 그것은 이 프리셋의 전제를 깨는 타입이다.
   둘을 갈라 가설과 근거로 보내고 나머지만 새 타입에 남긴다.
5. `templates/<타입>.md.tpl` 을 추가하고 [[객체-템플릿]] 의 수록 목록을 갱신한다.
