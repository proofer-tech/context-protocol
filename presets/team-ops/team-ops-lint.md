---
type: document
title: team-ops 무결성 점검과 조회 레시피
updated: 2026-10-29
---

# 무결성 점검과 조회 레시피

Dataview 와 `.base` 를 쓰지 않으므로 검증과 집계를 파일 스캔으로 한다.

점검 대상 주의: 여기 적힌 명령은 **프리셋을 적용한 대상 워크스페이스**에서 돌린다.
프리셋 폴더(`presets/team-ops/`) 자체를 훑으면 오탐이 난다. 설계 문서라 코드 펜스와
인라인 코드 안에 예시 위키링크와 예시 값이 설명으로 들어 있다. 프리셋 폴더는 위키링크
스윕과 Obsidian 잔재 검사에서 제외한다.

실행 위치 주의: 대상 워크스페이스가 Drive 마운트면 샌드박스 셸에서 안 보이는
cloud-only 파일이 있다. 빈 grep 결과는 아무것도 증명하지 못한다(GUIDE §3 하드 룰).
하네스의 호스트 파일 도구(Cowork 에서는 Desktop Commander 의 `start_search`)로 찾거나, 먼저 그 도구로
읽어 하이드레이트한 뒤 셸을 쓴다.

동시 편집 주의: 이 워크스페이스는 여러 사람이 쓴다. lint 를 돌린 결과가 5분 뒤에
틀릴 수 있다. **검사 결과를 파일에 박아두지 않는다.** 위반 목록을 노트로 만들면 그
노트가 곧 스테일해지고, 고쳐진 항목이 계속 위반으로 남아 아무도 안 보게 된다. 결과는
그 자리에서 보고하고 고칠 것만 고친다.

## 점검 목록

코어 규칙 1~6 은 프로토콜 lint 가 본다. 여기서는 프리셋이 더한 7~18 을 본다. 규칙
본문은 [[team-ops-schema]] 에 있다.

| # | 점검 | 종류 | 방법 |
|---|---|---|---|
| 7 | `type:` 이 허용 값인가 | 구조 | `objects/` 전체에서 `^type:` 수집 -> 10개 값(concept + document + 8타입)만 나와야 한다 |
| 8 | 필수 프로퍼티 존재 | 구조 | 타입별 PK 와 O 표시 필드를 루프로 대조 (아래 명령) |
| 9 | 위키링크 해소 | 구조 | 모든 `[[...]]` 를 수집해 동명 md 파일이 실재하는지 대조 |
| 10 | 술어 어휘 준수 | 구조 | `links:` 하위 키를 수집해 team-ops-schema 표와 대조 |
| 11 | 정/역 중복 | 구조 | 비정본 술어 9쌍을 스윕하고 상대 노트와 대조 (아래 명령) |
| 12 | 객체에 broader 없음 | 구조 | `objects/` 안 인스턴스 md 에 `broader:` 가 있으면 위반 |
| 13 | `ownedBy` 대상이 Team | 구조 | `owner:` 와 `links.ownedBy` **양쪽** 값이 `objects/teams/` 의 노트인지 대조 |
| 14 | superseded 에 supersededBy | 구조 | `status: superseded` 인데 대체자 링크가 없으면 위반 |
| 15 | Decision 에 context·rationale | 구조 | 두 필드가 없거나 비어 있으면 위반 |
| 16 | 1인칭 표현 없음 | 규율 | 화자 의존 표현 후보를 뽑아 사람이 판정 |
| 17 | `leftAt` 이면 `kind: alumni` | 구조 | 두 필드 조합 대조 |
| 18 | 회고 파생물 없는 sev1 | 규율 | 복구된 sev1 중 `triggers` 가 없는 것을 경고로 |
| 추가 | 날짜 폴더 없음 | 구조 | `action-log/` 하위에 디렉토리가 없어야 한다 |
| 추가 | Obsidian 잔재 없음 | 구조 | `.base` 파일, dataview 블록이 없어야 한다 |

## 구조 검사 명령 (하이드레이트 후 셸)

```sh
# 7. type 값 분포
grep -rh '^type:' objects/ | sort | uniq -c
#    나와야 하는 값: concept, document, 그리고 8개 타입명.
#    document 는 동명 서브폴더 안의 부속 노트가 쓴다(맨 아래 절).

# 8. 타입별 필수 프로퍼티. owner 는 links.ownedBy 로 적혀도 통과시킨다
for d in teams people initiatives decisions practices systems incidents metrics; do
  case "$d" in
    teams)       c=team;       req="slug name mission" ;;
    people)      c=person;     req="name" ;;
    initiatives) c=initiative; req="slug title status owner" ;;
    decisions)   c=decision;   req="slug title status decidedAt context rationale" ;;
    practices)   c=practice;   req="slug title kind owner" ;;
    systems)     c=system;     req="slug name kind owner" ;;
    incidents)   c=incident;   req="slug title severity startedAt owner" ;;
    metrics)     c=metric;     req="slug name kind definition owner" ;;
  esac
  for f in objects/$d/*.md objects/$d/*/*.md; do
    [ -f "$f" ] || continue
    case "$f" in */$c.md) continue;; esac
    for k in $req; do
      if [ "$k" = owner ]; then
        grep -qE '^owner: *[^ ]' "$f" || grep -q 'ownedBy' "$f" \
          || echo "missing owner: $f"
      else
        grep -qE "^$k: *[^ ]" "$f" || echo "missing $k: $f"
      fi
    done
  done
done

# 9. 위키링크 대상 목록 (파일명 인덱스와 대조할 좌변)
grep -rhoE '\[\[[^]|#]+' objects/ object-sets/ object-views/ datasources/ \
  | sed 's/\[\[//' | sort -u

# 9. 실재 노트 파일명 인덱스 (우변)
find . -name '*.md' -not -path './_*' -exec basename {} .md \; | sort -u

# 10. 사용된 술어 (links: 블록의 2단 들여쓰기 키)
grep -rhoE '^  [a-zA-Z]+:' objects/ | sort | uniq -c

# 11-a. 비정본 술어 전수 스윕. 템플릿은 정본 슬롯만 주므로 여기 걸리는 것은
#       전부 손으로 적힌 것이고, 상대 노트에 같은 사실이 있으면 위반이다
grep -rnE '^  (hasMember|participatesIn|owns|runs|pursues|decided|supersededBy|arisesFrom|observedBy|oncallFor|movedBy):' objects/

# 11-b. 실제 중복인지 상대 노트와 대조. 아래는 소속 쌍의 형태이고
#       나머지 쌍은 네 변수만 바꿔 같은 모양으로 돌린다
back=hasMember; fwd=memberOf            # 비정본 키 / 정본 키
srcdir=objects/teams; dstdir=objects/people
for f in $srcdir/*.md; do
  case "$f" in */team.md) continue;; esac
  a=$(basename "$f" .md)
  for b in $(grep -A20 "^  $back:" "$f" | grep -oE '\[\[[^]]+' | sed 's/\[\[//'); do
    g="$dstdir/$b.md"
    [ -f "$g" ] || continue
    grep -A20 "^  $fwd:" "$g" | grep -q "\[\[$a\]\]" \
      && echo "dup: $f <-> $g ($back/$fwd)"
  done
done

# 11-b 를 돌릴 목록 (비정본 -> 정본 / 비정본이 사는 폴더 -> 정본이 사는 폴더)
#   schema 요약표의 아홉 쌍이고, 소유 쌍은 키가 셋이라 줄이 열하나다
#   hasMember      -> memberOf         teams       -> people
#   participatesIn -> hasParticipant   people      -> initiatives
#   owns           -> ownedBy          teams       -> systems, metrics
#   runs           -> ownedBy          teams       -> practices
#   pursues        -> ownedBy          teams       -> initiatives
#   decided        -> decidedBy        people      -> decisions
#   supersededBy   -> supersedes       decisions   -> decisions
#   arisesFrom     -> triggers         decisions   -> incidents
#   observedBy     -> observes         systems     -> metrics
#   oncallFor      -> oncall           people      -> systems
#   movedBy        -> movesMetric      metrics     -> initiatives

# 12. 인스턴스에 broader 가 붙었는지
grep -rl '^broader:' objects/ \
  | grep -vE '/(team|person|initiative|decision|practice|system|incident|metric|team-knowledge)\.md$'

# 13. owner 가 Team 이 아닌 것. 두 자리를 함께 모은다
#     (a) frontmatter 최상단 owner:  (b) links: 아래 2단 들여쓰기 ownedBy:
#     템플릿이 (b) 를 기본 제공하므로 (a) 만 보면 위반의 대부분을 놓친다
{ grep -rhoE '^owner: *"?\[\[[^]]+' objects/ | sed 's/.*\[\[//'
  grep -rhA5 '^  ownedBy:' objects/ | grep -oE '\[\[[^]]+' | sed 's/\[\[//'
} | sort -u > /tmp/owners.txt
ls objects/teams/*.md | xargs -n1 basename | sed 's/\.md$//' | sort -u > /tmp/teams.txt
comm -23 /tmp/owners.txt /tmp/teams.txt

# owner 가 위키링크가 아니라 맨 문자열로 적힌 경우도 본다. 이름이 사람이면 위반이다
grep -rhE '^owner: *[^"[ ]' objects/ | sort -u

# 14. superseded 인데 대체자가 없는 결정
for f in $(grep -rl '^status: superseded' objects/decisions/); do
  grep -q 'supersededBy' "$f" || echo "no successor: $f"
done

# 15. context 또는 rationale 이 없는 결정
for f in objects/decisions/*.md; do
  case "$f" in */decision.md) continue;; esac
  grep -q '^context:' "$f" || echo "no context: $f"
  grep -q '^rationale:' "$f" || echo "no rationale: $f"
done

# 17. leftAt 이 있는데 alumni 가 아닌 사람
for f in $(grep -rlE '^leftAt: *[0-9]' objects/people/); do
  grep -q '^kind: alumni' "$f" || echo "still active: $f"
done

# 날짜 폴더
find action-log -type d

# Obsidian 잔재
find . -name '*.base'; grep -rl 'dataview' . --include='*.md'
```

9번의 좌변/우변 대조는 `comm -23` 로 차집합을 낸다. 좌변에만 남은 것이 dangling
링크다. 13번도 같은 형태이고, 여기서 나온 이름은 대개 사람 이름이다. 그것이 규칙 13
위반의 전형이다.

15번을 프로퍼티가 아니라 본문 섹션으로 쓰는 워크스페이스면 `^## 배경` 같은 헤딩으로
바꿔 검사한다. 템플릿이 둘 다 두므로 frontmatter 쪽을 기본으로 본다.

## 규율 검사 (16, 18)

**이 둘은 구조 검사가 아니다.** 명령이 내는 것은 위반 목록이 아니라 후보 목록이고,
판정은 사람이 한다. 자동화되지 않는 것이 결함이 아니라 성격이다.

이 프리셋이 실패하는 방식은 스키마 위반이 아니다. 스키마는 대체로 지켜진다. 실패는
**사람 의존과 회고 유실**로 오고, 둘 다 문법적으로는 완벽한 노트의 모습을 하고 있다.
lint 가 이것을 세지 않으면 아무도 세지 않는다.

그래서 이 두 항목은 나머지와 다르게 취급한다. 위반 수를 0 으로 만드는 것이 목표가
아니라, **주기적으로 세어서 늘고 있는지 보는 것**이 목표다. 분기마다 한 번, 또는
새 구성원이 합류할 때 돌린다.

### 16. 1인칭 표현

```sh
# 화자 의존 표현 후보
grep -rnE '(내가|제가|저는|나는|우리 팀장|우리팀장|팀장님|대표님|[가-힣]{1,4}님이)' \
  objects/ object-views/ object-sets/

# action-log 도 대상이다
grep -rnE '(내가|제가|저는|나는)' action-log/
```

판정 기준. 걸린 문장에서 **화자를 지우면 대상이 사라지는가**를 본다.

- 위반: "우리 팀장님이 승인하면 배포한다" -> 팀장이 바뀌면 누구를 말하는지 모른다.
  고치면 "리드 승인 후 배포한다" 또는 Person 위키링크.
- 위반: "내가 만든 파이프라인" -> 누가 썼느냐에 따라 다른 사람을 가리킨다.
- 위반 아님: "우리 팀이 소유한다" -> 이 워크스페이스에서 "우리 팀" 은 루트 Team
  하나로 고정돼 있다. 다만 루트 위키링크로 바꾸는 편이 낫다.
- 위반 아님: 장애 타임라인의 인용문. 당시 발화를 그대로 옮긴 것이면 화자가 명시돼
  있으므로 대상이 살아 있다.

`님` 을 검출어에 넣는 이유는 호칭이 1인칭보다 더 자주 새기 때문이다. 한국어 팀 문서
에서 가장 흔한 형태가 "OO님이 아는 영역" 이고, 그것이 [[team-ops]] 가 막으려는
사람 귀속의 정확한 모습이다.

### 18. 회고 파생물 없는 sev1

```sh
# 복구됐는데 triggers 가 없는 sev1
for f in $(grep -rl '^severity: sev1' objects/incidents/); do
  grep -qE '^resolvedAt: *[0-9]' "$f" || continue
  grep -q 'triggers' "$f" || echo "no follow-up: $f"
done

# 파생물이 있긴 한데 전부 dangling 인 경우도 본다
grep -rhoE 'triggers:.*' objects/incidents/ | sort -u
```

걸린 것은 셋 중 하나다.

1. 회고를 안 했다. 그러면 해야 한다.
2. 회고는 했는데 문서 안에만 적혔다. 액션 아이템을 Practice, Decision, Initiative 로
   꺼내고 `triggers` 로 건다. **이 경우가 가장 많다.**
3. 회고를 했고 정말로 바꿀 것이 없었다. 드물지만 있다. 그러면 Incident 본문에 그
   판단을 한 줄 적는다. 다음 사람이 같은 검사를 또 돌리지 않게 한다.

sev1 만 보는 것은 의도적이다. 전 등급에 걸면 경고가 너무 많아지고, 많아지면 아무도
안 본다. sev2 이하는 팀이 여유가 있을 때 본다.

같은 성격의 검사를 하나 더 둘 수 있다. `whyItExists` 가 빈 Practice 목록이다. 위반은
아니지만 "아무도 이유를 모르는 관행" 의 목록이고, 팀이 손대기 무서워하는 것들이
거기 모인다.

```sh
for f in objects/practices/*.md; do
  case "$f" in */practice.md) continue;; esac
  grep -qE '^whyItExists: *[^ ]' "$f" || echo "unexplained: $f"
done
```

## 조회 레시피 (Dataview 대체)

에이전트가 읽는 시점에 실행해 결과를 만들고, 결과를 파일에 박아두지 않는다.

```sh
# 진행 중인 이니셔티브
grep -l '^status: active' objects/initiatives/*.md

# 접힌 시도 (같은 제안이 다시 올라올 때 근거)
grep -l '^status: abandoned' objects/initiatives/*.md

# 뒤집힌 결정 추적: 현행 규범만 (뒤집힌 것 제외)
grep -l '^status: accepted' objects/decisions/*.md

# 뒤집힌 결정 추적: 옛 결정에서 현행으로 가는 사슬
#   1) 뒤집힌 것 목록
grep -l '^status: superseded' objects/decisions/*.md
#   2) 특정 결정을 대체한 결정 찾기 (백링크)
grep -rl 'supersedes:.*목요일-배포-금지' objects/decisions/
#   3) 한 슬러그의 전체 이력을 시간순으로
grep -H '^decidedAt:' $(grep -rl '배포' objects/decisions/) | sort -t: -k3

# 특정 시스템의 의존 역추적: 이게 죽으면 뭐가 같이 죽나
#   dependsOn 은 소비하는 쪽에 적히므로 역방향은 전문 검색이다
grep -rl '\[\[결제-게이트웨이\]\]' objects/systems/*.md

# 순방향 (이게 무엇에 기대는가) 은 노트 안에 있다
grep -A5 '^  dependsOn:' objects/systems/결제-게이트웨이.md

# 크리티컬 시스템에 런북이 없는 것
for f in $(grep -l '^tier: critical' objects/systems/*.md); do
  grep -qE '^runbook: *[^ ]' "$f" || echo "no runbook: $f"
done

# 온콜 조회: 지금 이 시스템 당번은 누구인가
grep -H -A2 '^  oncall:' objects/systems/*.md

# 온콜 조회: 이 사람이 지금 무엇을 맡고 있나
grep -rl '\[\[민수\]\]' objects/systems/*.md

# 이탈자 잔재 찾기: 나간 사람이 아직 어딘가에 살아 있는가
#   1) 이탈자 목록
grep -l '^kind: alumni' objects/people/*.md | xargs -n1 basename | sed 's/\.md$//'
#   2) 그 이름이 온콜이나 소유로 걸려 있는지 (여기서 나오면 고친다)
for n in $(grep -l '^kind: alumni' objects/people/*.md | xargs -n1 basename | sed 's/\.md$//'); do
  grep -rl "\[\[$n\]\]" objects/systems/ objects/practices/ objects/initiatives/ \
    | sed "s/^/alumni still linked ($n): /"
done

# 오래 리뷰 안 된 Practice
#   lastReviewedAt 이 아예 없는 것
for f in objects/practices/*.md; do
  case "$f" in */practice.md) continue;; esac
  grep -qE '^lastReviewedAt: *[0-9]' "$f" || echo "never reviewed: $f"
done
#   있는 것들을 오래된 순으로
grep -H '^lastReviewedAt:' objects/practices/*.md | sort -t: -k3 | head -20

# 특정 사람이 참여한 결정 (백링크)
grep -rl '\[\[민수\]\]' objects/decisions/

# 최근 장애가 건드린 시스템
grep -H -A3 '^  affects:' objects/incidents/*.md
```

이탈자 잔재 검사가 이 목록에서 가장 자주 무언가를 찾아낸다. 사람이 나갈 때 Person
노트는 고치는데 그 사람이 걸려 있던 `oncall` 과 `authoredBy` 는 남는다. 전자는
당번이 비어 있다는 뜻이라 즉시 고친다. 후자는 사실이므로 고치지 않는다. **작성자는
과거 사실이고 당번은 현재 상태다.** 검사 결과를 이 기준으로 가른다.

## object-sets 를 스테일하지 않게 두는 방법

정적 집합(수동 큐레이트)은 목록을 그대로 적는다. 사람이 고른 것이므로 자동 계산
대상이 아니다. 예: 새로 온 사람이 읽을 순서.

동적 집합은 **결과를 적지 않고 필터 명세를 적는다**. 노트 본문에 필터 조건과 위의
grep 한 줄을 함께 두고, 에이전트가 읽을 때 실행해 결과를 만든다.

```markdown
---
type: document
title: 현행-규범-목록
set_kind: dynamic
filter: "type=Decision AND status=accepted"
recipe: "grep -l '^status: accepted' objects/decisions/*.md"
updated: 2026-09-10
---

이 집합은 동적이다. 아래 목록은 마지막 확인 시점의 스냅샷이며 정본은 위 filter 다.
읽는 시점에 recipe 를 실행해 대조하고, 어긋나면 목록을 갱신하고 updated 를 bump 한다.

- [[...]]
```

여러 사람이 쓰는 워크스페이스에서 이 규율이 개인 워크스페이스보다 더 중요하다.
스냅샷이 틀렸을 때 누가 틀렸는지 다투게 되는데, 정본이 filter 라고 적혀 있으면 그
다툼이 없다.

`unconfirmed` 집합은 특히 동적으로 둔다. 인테이크에서 나온 미확정 문장들이고
([[team-ops-intake]]), 팀이 확인할 때마다 줄어야 하는 목록이다.

```sh
grep -rl 'unconfirmed' objects/
```

## 부속 서브폴더의 고아 방지

동명 서브폴더(`objects/incidents/<PK>/`) 는 개념 폴더가 아니다. 그래서 그 안의 md 는
위치만으로는 소속이 결정되지 않는다. 인덱스 노트와 부속 노트 모두 frontmatter 에
소속을 적는다.

```yaml
# 인덱스 노트 objects/incidents/2026-08-결제-지연/2026-08-결제-지연.md
type: Incident
subject: ["[[incident]]"]

# 부속 노트 objects/incidents/2026-08-결제-지연/대응-로그-발췌.md
type: document
subject: ["[[incident]]"]
links:
  relatedObjects: ["[[2026-08-결제-지연]]"]
```

소속은 `subject:` 한 곳으로 끝낸다. 상위 인덱스를 가리키는 데 `incident:` 같은 임의
키를 쓰지 않는다. 술어 표에 없는 키는 규칙 10 위반이다. 다용도 연결로 등재된
`relatedObjects` 를 쓰거나 본문 위키링크로 가리킨다([[team-ops-schema]] 보조 술어).

점검: 서브폴더 안의 md 중 `subject:` 없는 것을 찾는다. 이어서 임의 키가 쓰였는지도 본다.

```sh
for f in $(find objects -mindepth 3 -name '*.md'); do
  grep -q '^subject:' "$f" || echo "orphan: $f"
done

# 부속 노트가 임의 키로 상위를 가리키는지 (타입명을 그대로 키로 쓴 경우)
grep -rnE '^(team|person|initiative|decision|practice|system|incident|metric): *"?\[\[' objects/
```

이 프리셋은 서브폴더를 personal-rag 보다 적극적으로 쓰므로([[team-ops-layout]])
이 검사가 더 자주 걸린다. 여러 사람이 각자 부속 노트를 만들고, 손으로 만든 노트에는
대개 `subject` 가 없다. 템플릿을 `_context-protocol/templates/` 에 복사해 두는 이유가 이것이다.
