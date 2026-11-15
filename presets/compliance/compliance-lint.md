---
type: document
title: compliance 무결성 점검과 조회 레시피
updated: 2026-10-29
---

# 무결성 점검과 조회 레시피

Dataview 와 `.base` 를 쓰지 않으므로 검증과 집계를 파일 스캔으로 한다.

이 문서의 점검은 두 종류다. **구조 점검**은 그래프가 온전한지 본다. **실질 점검**은
우리가 실제로 지키고 있는지 본다. [[compliance-schema]] 의 규칙 13~18 이 두 종류를
일부러 섞어 놓았고, 여기서 그것을 갈라 놓는다.

갈라 놓는 이유는 대응이 다르기 때문이다. 구조 점검 실패는 **데이터 오류**라 그 자리에서
고친다. 실질 점검 실패는 **컴플라이언스 결함**이라 고칠 수 없다. 증거가 없는 것을 lint
가 고칠 방법은 없다. 그것은 Finding 후보이고 사람에게 보고할 것이다
([[compliance-actions]] "Finding 으로 승격하는 기준").

이 둘을 섞어 한 목록으로 내면 진짜 급한 것이 오타 고침 사이에 묻힌다.

점검 대상 주의: 여기 적힌 명령은 **프리셋을 적용한 대상 워크스페이스**에서 돌린다.
프리셋 폴더(`presets/compliance/`) 자체를 훑으면 오탐이 난다. 설계 문서라 코드 펜스와
인라인 코드 안에 예시 위키링크와 예시 상태값이 설명으로 들어 있다. 프리셋 폴더는
위키링크 스윕과 상태값 검사에서 제외한다.

실행 위치 주의: 대상 워크스페이스가 Drive 마운트면 샌드박스 셸에서 안 보이는
cloud-only 파일이 있다. 빈 grep 결과는 아무것도 증명하지 못한다(GUIDE §3 하드 룰).
하네스의 호스트 파일 도구(Cowork 에서는 Desktop Commander 의 `start_search`)로 찾거나, 먼저 그 도구로
읽어 하이드레이트한 뒤 셸을 쓴다. **이 도메인에서 이 함정은 특히 위험하다.** "증거 없는 의무 0건" 이라는 빈
결과를 그대로 보고하면 그것이 그대로 거짓 안심이 된다.

## 구조 점검

그래프가 온전한가. 실패하면 그 자리에서 고친다.

| # | 점검 | 방법 |
|---|---|---|
| 7 | `type:` 이 허용 값인가 | `objects/` 전체에서 `^type:` 수집 -> 10개 값(concept + document + 8타입)만 나와야 한다 |
| 8 | 필수 프로퍼티 존재 | 타입별로 PK 키(`slug:` 또는 `name:`)와 필수 필드가 있는지 확인 |
| 9 | 위키링크 해소 | 모든 `[[...]]` 를 수집해 동명 md 파일이 실재하는지 대조 |
| 10 | 술어 어휘 준수 | `links:` 하위 키를 수집해 compliance-schema 표와 대조 |
| 11 | 정/역 중복 | 정본 방향 요약표의 5쌍에 대해 양쪽 노트에 동시에 적힌 사실을 찾는다. 아래 명령 |
| 12 | 객체에 broader 없음 | `objects/` 안 인스턴스 md 에 `broader:` 가 있으면 위반 |
| 13 | 책임 값이 Unit 인가 | 링크(`ownedBy` 등)와 프로퍼티(`owner` 등) 양쪽을 본다. 위키링크가 아닌 평문 값과, 위키링크지만 `objects/units/` 에 없는 대상을 잡는다. 아래 명령 |
| 추가 | 날짜 폴더 없음 | `action-log/` 하위에 디렉토리가 없어야 한다 |
| 추가 | Obsidian 잔재 없음 | `.base` 파일, ` ```dataview ` 블록이 없어야 한다 |

규칙 13 이 여기 있는 이유: 사람 이름이 들어간 것은 컴플라이언스 결함이 아니라 모델링
오류다. 고치는 방법이 명확하다. 해당 사람이 속한 Unit 을 만들고 링크를 옮기고 이름은
`currentHolder` 로 내린다.

규칙 13 을 검사할 때 링크만 보면 안 된다. **위반은 평문으로 나타난다.** `ownedBy` 에
사람 이름을 적는 사람은 위키링크로 적지 않고 그냥 "김철수 팀장" 이라고 쓴다. 링크만
수집하는 명령은 그 줄에서 아무것도 못 뽑고 조용히 통과한다. 그리고 필수 프로퍼티는
`owner` 쪽인데(Obligation, Control, Regulation) 그것을 안 보면 가장 흔한 자리를
통째로 놓친다. 아래 명령은 프로퍼티와 링크를 함께 보고 **위키링크가 아닌 값**을
먼저 잡는다.

`auditor` 는 이 검사에서 제외한다. 외부 수행자의 이름을 적는 전용 칸이라 평문이 정상
이다([[compliance-object-types]] Audit). 사내 주체는 이 칸을 비우고 `performedBy` 로
건다. 그래서 `auditor` 는 값이 있는데 `kind: internal` 인 경우만 따로 본다.

## 실질 점검 (우리가 지키고 있나)

사슬이 실제로 이어져 있는가. 실패해도 lint 가 고칠 수 없다. 사람에게 보고한다.

| # | 점검 | 무엇을 뜻하나 |
|---|---|---|
| 14 | Obligation 이 `requiredBy` 를 갖는가 | 근거 없는 의무. 어디서 왔는지 아무도 모른다 |
| 15 | `status: met` 이 유효한 Evidence 를 갖는가 | 근거 없는 충족 선언. 감사에서 가장 먼저 무너진다 |
| 16 | Evidence 의 기간이 Obligation 주기를 덮는가 | 기한 지난 증거. 붙어 있으나 마나다 |
| 17 | 열린 Finding 의 기한이 남아 있는가 | 시정 지연. 이 워크스페이스에서 가장 급한 항목 |
| 18 | `notApplicable` 이 이유를 갖는가 | 미검토를 비해당으로 위장한 것 |

14 는 경계에 있다. 구조로도 읽히지만 실질에 둔다. 근거를 못 찾은 것은 파일을 잘못 쓴
것이 아니라 **아직 확인하지 못한 것**이고, 대응이 "링크를 고친다" 가 아니라 "법무에
확인한다" 이기 때문이다.

17 은 lint 가 잡되 데이터 오류가 아니다. 값은 정확하고 현실이 나쁜 것이다. 이것을
lint 에 넣은 것은 의도한 설계다([[compliance-schema]]).

실질 점검 결과는 **매번 같은 형식으로 보고한다.** 건수와 목록, 그리고 각 항목이
Finding 후보인지 여부. 숫자만 보고하면 다음 세션이 무엇이 바뀌었는지 모른다.

## 구조 점검 명령 (하이드레이트 후 셸)

```sh
# 7. type 값 분포
grep -rh '^type:' objects/ | sort | uniq -c

# 8. PK 누락 (slug 를 쓰는 7개 타입)
for d in statutes regulations obligations controls evidence audits findings; do
  for f in objects/$d/*.md; do
    grep -q '^slug:' "$f" || echo "no-pk: $f"
  done
done

# 9. 위키링크 대상 목록 (파일명 인덱스와 대조할 좌변)
grep -rhoE '\[\[[^]|#]+' objects/ object-sets/ object-views/ datasources/ \
  | sed 's/\[\[//' | sort -u

# 9. 실재 노트 파일명 인덱스 (우변)
find . -name '*.md' -not -path './_*' -exec basename {} .md \; | sort -u

# 10. 사용된 술어 (links: 블록의 2단 들여쓰기 키)
grep -rhoE '^  [a-zA-Z]+:' objects/ | sort | uniq -c

# 12. 인스턴스에 broader 가 붙었는지
grep -rl '^broader:' objects/ \
  | grep -vE '/(statute|regulation|obligation|control|evidence|audit|finding|unit|compliance-chain)\.md$'

# 11. 정/역 중복 (정본 방향 요약표의 5쌍)
# 각 쌍마다 정본 쪽 노트가 X 를 가리키고 동시에 비정본 쪽 노트가 되받아 가리키면 위반.
check_pair() {   # $1=비정본 폴더  $2=비정본 술어  $3=정본 폴더  $4=정본 술어
  for f in objects/$1/*.md; do
    [ -e "$f" ] || continue
    sed -n "/^  $2:/,/^  [a-zA-Z]*:/p" "$f" | grep -oE '\[\[[^]|#]+' | sed 's/\[\[//' \
    | while read -r t; do
        g="objects/$3/$t.md"
        [ -e "$g" ] || continue
        sed -n "/^  $4:/,/^  [a-zA-Z]*:/p" "$g" \
          | grep -q "\[\[$(basename "$f" .md)\]\]" \
          && echo "dup-$2/$4: $f <-> $g"
      done
  done
}
check_pair regulations derives        obligations requiredBy
check_pair obligations implementedBy  controls    implements
check_pair controls    produces       evidence    producedBy
check_pair units       accountableFor obligations ownedBy
check_pair units       accountableFor controls    ownedBy
check_pair units       accountableFor regulations ownedBy
check_pair units       accountableFor findings    ownedBy
check_pair audits      raises         findings    raisedBy

# 13. 책임 값이 실릴 수 있는 자리를 전부 펼친다.
#   프로퍼티형: ^owner: / ^approvedBy: / ^collectedBy:  (필수 프로퍼티가 여기 있다)
#   링크형:     ^  ownedBy: 등. 값이 같은 줄에 오기도 하고 다음 줄들에 - 로 붙기도 한다
resp_values() {
  awk '
    /^(owner|approvedBy|collectedBy):[[:space:]]*[^[:space:]]/ {
      v=$0; sub(/^[a-zA-Z]+:[[:space:]]*/,"",v); print v; next }
    /^  (ownedBy|performedBy|collectedBy|accountableFor):/ {
      inb=1; v=$0; sub(/^  [a-zA-Z]+:[[:space:]]*/,"",v); if (v!="") print v; next }
    inb && /^[[:space:]]+-[[:space:]]*/ {
      v=$0; sub(/^[[:space:]]*-[[:space:]]*/,"",v); print v; next }
    { inb=0 }
  ' "$1"
}

# 13-a. 위키링크가 아닌 값 (평문). 가장 흔한 위반이고 링크만 보는 검사는 이것을 놓친다
for f in $(find objects -name '*.md'); do
  resp_values "$f" | tr -d '"' | grep -v '^\[\[' | sed "s|^|plain-owner: $f: |"
done

# 13-b. 위키링크지만 units 폴더에 없는 대상
for f in $(find objects -name '*.md'); do resp_values "$f"; done \
  | grep -oE '\[\[[^]|#]+' | sed 's/\[\[//' | sort -u > /tmp/cl-owners
ls objects/units/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort -u > /tmp/cl-units
comm -23 /tmp/cl-owners /tmp/cl-units | sed 's/^/not-a-unit: /'

# 13-c. auditor 는 외부 수행자 전용 칸이라 평문이 정상이다. 사내 점검에 값이 있으면 의심
grep -l '^kind: internal' objects/audits/*.md 2>/dev/null \
  | xargs -r grep -l '^auditor:[[:space:]]*[^[:space:]]' \
  | sed 's/^/internal-audit-has-auditor: /'

# 날짜 폴더
find action-log -type d

# Obsidian 잔재
find . -name '*.base'; grep -rl '```dataview' .
```

9 의 좌변/우변 대조는 `comm -23` 로 차집합을 낸다. 좌변에만 남은 것이 dangling 링크다.
13-b 는 같은 대조를 미리 넣어 두었다.

13-a 가 13-b 보다 중요하다. **평문 검사가 먼저 돌아야 한다.** 링크 대조는 위키링크로
적힌 것만 보므로, 사람 이름을 그냥 문자열로 적은 줄은 13-b 에서 영원히 안 걸린다.
13-a 의 출력이 0줄인 것과 검사가 안 돈 것을 혼동하지 않는다.

`resp_values` 를 grep 한 줄로 대신하지 않는다. 링크 값은 같은 줄에 오기도 하고
`links:` 맵 아래에 `-` 목록으로 붙기도 하는데, `^  ownedBy:.*` 같은 grep 은 목록형에서
콜론 뒤가 비어 있어 아무것도 못 뽑는다. 목록형이 기본 표기이므로 그 grep 은 사실상
전부를 놓친다. 두 표기를 한 함수로 펼쳐 놓고 프로퍼티와 링크를 같은 목록으로 다루는
이유가 그것이다.

11 의 `check_pair` 는 `links:` 맵의 2단 들여쓰기를 전제한다. 본문 섹션에 위키링크로만
적힌 관계는 이 명령이 못 잡으므로, 본문 기재가 많은 워크스페이스는 정본 쪽 파일명으로
역방향 폴더를 훑는 방식으로 표본을 더 본다. 비정본 슬롯을 템플릿에서 뺀 이유가 이
검사를 싸게 만들기 위해서다([[object-template]]).

## 실질 점검 명령

```sh
# 14. requiredBy 없는 의무
grep -rL 'requiredBy' objects/obligations/*.md

# 15. met 인데 자기를 가리키는 증거가 없는 의무
for f in objects/obligations/*.md; do
  grep -q '^status: met' "$f" || continue
  k=$(basename "$f" .md)
  grep -rql "\[\[$k\]\]" objects/evidence/ || echo "met-no-evidence: $k"
done

# 16. coversTo 가 오늘로부터 1년 이상 지난 증거 (연 단위 의무 기준의 거친 1차 필터)
grep -H '^coversTo:' objects/evidence/*.md \
  | awk -v cut="$(date -d '1 year ago' +%F 2>/dev/null || date -v-1y +%F)" \
        -F'coversTo: ' '$2 < cut {print "stale-evidence: " $0}'

# 17. 열린 채 기한 넘긴 Finding
for f in objects/findings/*.md; do
  grep -qE '^closedAt: *[0-9]' "$f" && continue
  d=$(grep -m1 '^dueAt:' "$f" | sed 's/^dueAt: *//')
  [ -n "$d" ] && [ "$d" \< "$(date +%F)" ] && echo "overdue-finding: $f (기한 $d)"
done

# 18. 근거 없는 notApplicable
for f in $(grep -rl '^status: notApplicable' objects/obligations/); do
  grep -qE '^summary: *[^ ]' "$f" || echo "na-no-reason: $f"
done
```

16 의 1년 기준은 거친 1차 필터다. **정확한 판정은 의무의 `cadence` 별로 다르다.**
분기 의무는 90일, 월 의무는 30일이 기준이고, 각 의무의 `graceDays` 를 더한다. 자동화
하려면 의무마다 기준을 읽어 비교해야 하므로, 위 명령으로 후보를 좁힌 뒤 사람이 판정
하거나 에이전트가 해당 의무 노트를 읽고 판정한다.

17 의 문자열 날짜 비교는 `YYYY-MM-DD` 형식일 때만 맞다. 날짜 형식이 섞여 있으면
구조 점검 8 에서 먼저 걸린다.

## 조회 레시피 (Dataview 대체)

에이전트가 읽는 시점에 실행해 결과를 만들고, 결과를 파일에 박아두지 않는다.

```sh
# 증거 없는 의무 (사슬이 끊긴 자리)
for f in objects/obligations/*.md; do
  k=$(basename "$f" .md)
  grep -rql "\[\[$k\]\]" objects/evidence/ || echo "$k"
done

# 통제 없는 의무 (증거 이전 단계에서 끊긴 자리)
for f in objects/obligations/*.md; do
  k=$(basename "$f" .md)
  grep -rql "\[\[$k\]\]" objects/controls/ || echo "$k"
done

# 기한 지난 증거 (실질 점검 16 과 같은 명령. 위 참조)

# 열린 채 기한 넘긴 Finding (실질 점검 17 과 같은 명령. 위 참조)

# 근거 없는 notApplicable (실질 점검 18 과 같은 명령. 위 참조)

# 특정 부서가 지는 책임 전부 (역추적)
grep -rl '\[\[정보보호팀\]\]' objects/

# 이번 분기에 실행돼야 하는 통제
grep -l '^  kind: quarterly' objects/controls/*.md

# 수동 통제 목록 (증거가 가장 잘 끊기는 자리)
grep -l '^automation: manual' objects/controls/*.md

# 특정 법령에 매달린 사슬 전체 (위에서 아래로)
grep -rl '\[\[개인정보보호법-29조\]\]' objects/

# 폐지되지 않은 현행 규정
grep -L '^effectiveTo: *[0-9]' objects/regulations/*.md

# 진행 중인 점검
grep -l '^result: inProgress' objects/audits/*.md
```

앞의 다섯 개가 이 워크스페이스의 핵심 질의다. 나머지는 보조다. 사슬 추적과 공백 탐지가
이 도메인의 주 질의라는 것이 [[compliance]] "원본 대비" 2번이다.

## object-sets 와 object-views 를 스테일하지 않게 두는 방법

정적 집합(수동 큐레이트)은 목록을 그대로 적는다. 사람이 고른 것이므로 자동 계산 대상이
아니다. 예: 이번 감사 대응 범위, 중점 관리 규정.

동적 집합은 **결과를 적지 않고 필터 명세를 적는다**. 노트 본문에 필터 조건과 위의 명령
한 줄을 함께 두고, 에이전트가 읽을 때 실행해 결과를 만든다.

```markdown
---
type: document
title: 증거-없는-의무
set_kind: dynamic
filter: "type=Obligation AND NOT EXISTS(evidenceFor)"
recipe: "for f in objects/obligations/*.md; do k=$(basename \"$f\" .md); grep -rql \"[[$k]]\" objects/evidence/ || echo \"$k\"; done"
updated: 2026-09-10
---

이 집합은 동적이다. 아래 목록은 마지막 확인 시점의 스냅샷이며 정본은 위 filter 다.
읽는 시점에 recipe 를 실행해 대조하고, 어긋나면 목록을 갱신하고 updated 를 bump 한다.

- [[...]]
```

이렇게 두면 목록이 틀렸을 때 무엇이 정본인지 다툼이 없다. 라이브 뷰의 부재를 규율로
메우는 지점이 정확히 여기다.

**이 도메인에서 스냅샷의 날짜가 특히 중요하다.** 이행 현황표를 감사인에게 보여주는
일이 실제로 일어나고, 그때 그 표가 언제 기준인지 말할 수 없으면 표 전체가 무용해진다.
`updated` 를 bump 하지 않은 뷰는 없는 것보다 나쁘다.

## 부속 서브폴더의 고아 방지

동명 서브폴더(`objects/regulations/<PK>/`) 는 개념 폴더가 아니다. 그래서 그 안의 md 는
위치만으로는 소속이 결정되지 않는다. 인덱스 노트와 부속 노트 모두 frontmatter 에
소속을 적는다.

**부속 노트는 `subject` 와 상위 타입명 키를 병기한다.** 둘 중 하나로 줄이지 않는다.
`subject` 는 타입 개념을 가리켜 고아 검사를 통과시키고, 상위 타입명 키는 이 서브폴더의
어느 인덱스에 딸렸는지를 가리킨다. 가리키는 대상이 개념과 인스턴스로 다르다. 규약은
[[compliance-layout]] 의 "부속물이 쌓이는 객체의 서브폴더 규칙".

```yaml
# 인덱스 노트 objects/regulations/foo/foo.md
type: Regulation
subject: ["[[regulation]]"]

# 부속 노트 objects/regulations/foo/개정-대비표.md
type: document
subject: ["[[regulation]]"]
regulation: "[[foo]]"
```

점검: 서브폴더 안의 md 중 `subject:` 없는 것을 찾는다. 부속 노트가 상위 인덱스를
가리키는 키를 함께 갖는지도 본다.

```sh
for f in $(find objects -mindepth 3 -name '*.md'); do
  grep -q '^subject:' "$f" || echo "orphan: $f"
done

# 인덱스 노트가 아닌데 상위 인덱스를 가리키는 키가 없는 부속 노트
for f in $(find objects -mindepth 3 -name '*.md'); do
  d=$(basename "$(dirname "$f")")
  [ "$(basename "$f" .md)" = "$d" ] && continue      # 인덱스 노트는 제외
  grep -qE '^(statute|regulation|obligation|control|evidence|audit|finding|unit): *"?\[\[' "$f"     || echo "no-parent-key: $f"
done
```

## 점검 주기

구조 점검은 [[compliance-apply]] Step 7 과 큰 변경 뒤에 돈다.

실질 점검은 **정기로 돈다.** 이 프리셋의 실질 점검은 파일이 바뀌지 않아도 결과가
바뀐다. 아무도 아무것도 안 해도 시간이 지나면 증거가 만료되고 기한이 넘어간다. 그래서
"변경했으니 돌린다" 가 아니라 "달이 바뀌었으니 돌린다" 다.

결과는 `object-views/` 의 이행 현황 뷰에 반영하고 action-log 에 한 줄 남긴다. 점검
자체가 이 워크스페이스에서 정기 업무이므로, 그것을 Obligation 으로 등록해 두는 조직도
있다. 그렇게 하면 이 lint 를 도는 것이 Control 이 되고 그 결과 보고가 Evidence 가 된다.
자기 참조지만 순환은 아니다.
