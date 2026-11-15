---
type: document
title: personal-rag 무결성 점검과 조회 레시피
updated: 2026-10-29
---

# 무결성 점검과 조회 레시피

Dataview 와 `.base` 를 쓰지 않으므로 검증과 집계를 파일 스캔으로 한다. 원본에서
`functions/` 의 Dataview 쿼리와 `_views/integrity-lint.md` 가 하던 일을 여기서 대신한다.

점검 대상 주의: 여기 적힌 명령은 **프리셋을 적용한 대상 워크스페이스**에서 돌린다.
프리셋 폴더(`presets/personal-rag/`) 자체를 훑으면 오탐이 난다. 설계 문서라 코드
펜스와 인라인 코드 안에 예시 위키링크(`[[김아무개]]`, `[[personal-knowledge-graph]]`,
`[[foo]]`)와 문자열 "dataview" 가 설명으로 들어 있다. 프리셋 폴더는 위키링크 스윕과
Obsidian 잔재 검사에서 제외한다.

실행 위치 주의: 대상 워크스페이스가 Drive 마운트면 샌드박스 셸에서 안 보이는
cloud-only 파일이 있다. 빈 grep 결과는 아무것도 증명하지 못한다(GUIDE §3 하드 룰).
하네스의 호스트 파일 도구(Cowork 에서는 Desktop Commander 의 `start_search`)로 찾거나, 먼저 그 도구로
읽어 하이드레이트한 뒤 셸을 쓴다.

## 점검 목록

코어 규칙 1~6 은 프로토콜 lint 가 본다. 여기서는 프리셋이 더한 7~12 를 본다.

| # | 점검 | 방법 |
|---|---|---|
| 7 | `type:` 이 허용 값인가 | `objects/` 전체에서 `^type:` 수집 -> 8개 값(concept + 7타입)만 나와야 한다 |
| 8 | 필수 프로퍼티 존재 | 타입별로 PK 키(`name:` 또는 `slug:`)와 필수 필드가 있는지 확인 |
| 9 | 위키링크 해소 | 모든 `[[...]]` 를 수집해 동명 md 파일이 실재하는지 대조 |
| 10 | 술어 어휘 준수 | `links:` 하위 키를 수집해 personal-rag-schema 표와 대조 |
| 11 | 정/역 중복 | 같은 사실이 양쪽 노트에 정방향+역방향으로 동시에 있는지 표본 확인 |
| 12 | 객체에 broader 없음 | `objects/` 안 인스턴스 md 에 `broader:` 가 있으면 위반 |
| 추가 | 날짜 폴더 없음 | `action-log/` 하위에 디렉토리가 없어야 한다 |
| 추가 | Obsidian 잔재 없음 | `.base` 파일, ` ```dataview ` 블록이 없어야 한다 |

## 점검 명령 (하이드레이트 후 셸)

```sh
# 7. type 값 분포
grep -rh '^type:' objects/ | sort | uniq -c

# 9. 위키링크 대상 목록 (파일명 인덱스와 대조할 좌변)
grep -rhoE '\[\[[^]|#]+' objects/ object-sets/ object-views/ datasources/ \
  | sed 's/\[\[//' | sort -u

# 9. 실재 노트 파일명 인덱스 (우변)
find . -name '*.md' -not -path './_*' -exec basename {} .md \; | sort -u

# 10. 사용된 술어 (links: 블록의 2단 들여쓰기 키)
grep -rhoE '^  [a-zA-Z]+:' objects/ | sort | uniq -c

# 12. 인스턴스에 broader 가 붙었는지
grep -rl '^broader:' objects/ | grep -vE '/(person|organization|project|event|place|idea|artifact|personal-knowledge-graph)\.md$'

# 날짜 폴더
find action-log -type d

# Obsidian 잔재
find . -name '*.base'; grep -rl '```dataview' .
```

위 좌변/우변 대조는 `comm -23` 로 차집합을 낸다. 좌변에만 남은 것이 dangling 링크다.

## 조회 레시피 (Dataview 대체)

원본 `functions/README.md` 의 쿼리를 grep 으로 번역한 것이다. 에이전트가 읽는 시점에
실행해 결과를 만들고, 결과를 파일에 박아두지 않는다.

```sh
# 진행중인 프로젝트  (Dataview: WHERE status = "active")
grep -l '^status: active' objects/projects/*.md

# 올해 만난 사람      (WHERE date(firstMet).year = this year)
grep -l '^firstMet: 2026' objects/people/*.md

# 마일스톤 사건 목록  (WHERE category = "milestone", SORT startDate DESC)
grep -H '^startDate:' $(grep -l '^category: milestone' objects/events/*.md) | sort -t: -k3 -r

# 스킬 인벤토리       (WHERE kind = "skill")
grep -l '^kind: skill' objects/ideas/*.md

# 특정 인물의 등장 지점 (관계망 역추적)
grep -rl '\[\[임한솔\]\]' objects/ object-views/

# 폐기된 식별자/도메인 (status: past 를 가진 레지스트리 행)
grep -rn 'past' objects/*/*.md | grep -E 'handle|email|account|url'
```

## object-sets 를 스테일하지 않게 두는 방법

정적 집합(수동 큐레이트)은 목록을 그대로 적는다. 사람이 고른 것이므로 자동 계산 대상이
아니다. 예: 대표 산출물, 가까운 친구.

동적 집합은 **결과를 적지 않고 필터 명세를 적는다**. 노트 본문에 필터 조건과 위의
grep 한 줄을 함께 두고, 에이전트가 읽을 때 실행해 결과를 만든다.

```markdown
---
type: document
title: 진행중인-프로젝트
set_kind: dynamic
filter: "type=Project AND status=active"
recipe: "grep -l '^status: active' objects/projects/*.md"
updated: 2026-08-18
---

이 집합은 동적이다. 아래 목록은 마지막 확인 시점의 스냅샷이며 정본은 위 filter 다.
읽는 시점에 recipe 를 실행해 대조하고, 어긋나면 목록을 갱신하고 updated 를 bump 한다.

- [[...]]
```

이렇게 두면 목록이 틀렸을 때 무엇이 정본인지 다툼이 없다. 라이브 뷰의 부재를 규율로
메우는 지점이 정확히 여기다.

## 부속 서브폴더의 고아 방지

동명 서브폴더(`objects/projects/<PK>/`) 는 개념 폴더가 아니다. 그래서 그 안의 md 는
위치만으로는 소속이 결정되지 않는다. 인덱스 노트와 부속 노트 모두 frontmatter 에
소속을 적는다.

```yaml
# 인덱스 노트 objects/projects/foo/foo.md
type: Project
subject: ["[[project]]"]

# 부속 노트 objects/projects/foo/분석.md
type: document
subject: ["[[project]]"]
project: "[[foo]]"
```

점검: 서브폴더 안의 md 중 `subject:` 없는 것을 찾는다.

```sh
for f in $(find objects -mindepth 3 -name '*.md'); do
  grep -q '^subject:' "$f" || echo "orphan: $f"
done
```
