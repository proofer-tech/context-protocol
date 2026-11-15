---
type: concept
scheme: context-protocol
pref_label_ko: 객체 템플릿
pref_label_en: Object template
broader: "[[compliance]]"
related:
definition: compliance 객체 타입별 인스턴스 생성 템플릿. frontmatter 필수 키와 본문 섹션 골격을 담아 새 객체가 필수 프로퍼티와 사슬 링크를 빠뜨리지 않게 한다.
updated: 2026-09-10
---

# 객체 템플릿 (폴더 개념)

이 노트는 `presets/compliance/templates/` 폴더의 개념 노트다. 이 폴더 안의
`.md.tpl` 파일들이 타입별 템플릿이다.

## 왜 `.md.tpl` 인가

템플릿의 frontmatter 는 `type: Obligation` 같은 객체 타입 값을 갖는다. 이를 `.md` 로
두면 lint 가 프로퍼티가 텅 빈 실제 인스턴스로 오인하고 규칙 8(필수 프로퍼티) 위반으로
잡는다. 비-md 파일은 메타 검사 대상이 아니므로(GUIDE §10 유추 기준) `.md.tpl` 로 둔다.

부수 효과로 "이건 채워 넣을 껍데기"라는 신호가 파일명에 남는다.

## 수록 템플릿

- `statute.md.tpl`
- `regulation.md.tpl`
- `obligation.md.tpl`
- `control.md.tpl`
- `evidence.md.tpl`
- `audit.md.tpl`
- `finding.md.tpl`
- `unit.md.tpl`

## 사용법

에이전트: 이 폴더의 해당 `.md.tpl` 을 읽고, 플레이스홀더를 채워
`objects/<type>/<PK>.md` 로 쓴다. `{{title}}` 은 파일명(PK), `{{date}}` 은 오늘 날짜
(절대값)로 치환한다. 값이 없는 키는 지우지 말고 비워 둔다. 나중에 채울 슬롯이
남아 있는 것이 그 자체로 정보다. 단 필수 프로퍼티(각 타입의 O 표시)는 비우지 않는다.

Obsidian 을 쓰는 워크스페이스: `_context-protocol/templates/` 로 복사하고 `.tpl` 을 떼면 Templater
가 `{{title}}` / `{{date:YYYY-MM-DD}}` 를 처리한다.

관계 섹션의 빈 `[[ ]]` 는 채우거나 섹션째로 지운다. 빈 위키링크를 남기면 lint 규칙 9
(링크 해소)에서 dangling 으로 잡힌다.

## links 맵에 역방향 술어를 두지 않았다

[[compliance-schema]] 가 같은 사실의 정본 방향을 정해 두었고, 템플릿의 `links:` 맵은
**정본 방향만** 슬롯으로 갖는다. 역방향 술어를 슬롯으로 두면 빈칸이 채우라는 신호로
읽혀서 양쪽 기재(규칙 11 위반)를 부른다.

| 타입 | `links:` 슬롯에 없는 것 | 정본은 어디에 |
|---|---|---|
| Regulation | `derives` | 의무 쪽 `requiredBy` |
| Obligation | `implementedBy` | 통제 쪽 `implements` |
| Control | `produces` (링크 슬롯으로는 없음) | 증거 쪽 `producedBy`, `evidenceFor` |
| Audit | `raises` | 지적 쪽 `raisedBy` |
| Unit | `accountableFor` | 각 객체 쪽 `ownedBy` |

대신 각 템플릿 본문에 그 사실을 뽑는 grep 한 줄을 섹션으로 두었다. 역방향은 적는
것이 아니라 **조회하는 것**이라는 규약이 템플릿 안에서 반복된다.

Control 의 `produces` 만 처리가 다르다. 지우지 않고 `links:` 맵 **밖에** 남겨 두었다.
어휘에는 있고 쓸 자리도 있지만, 값이 인스턴스 목록이 아니라 "어떤 종류의 증거가
나오는지" 한 줄이기 때문이다([[compliance-schema]] 사슬 절). 링크 슬롯 안에 두면 빈
배열이 증거를 하나씩 채우라는 신호로 읽히고, 그러면 통제 노트가 실행 회차만큼 길어진다.

정말로 역방향을 적어야 하는 예외(Unit 이 아주 커져서 훑기가 필요한 경우)는 슬롯을
손으로 추가한다. 그때도 양쪽에 적지 않는다. 점검 명령은 [[compliance-lint]] 규칙 11 이다.

## 8종이 공통으로 갖는 슬롯

[[compliance-schema]] 의 공유 프로퍼티와 HasIdentity 인터페이스가 요구하는 것들이라
타입과 무관하게 8종 전부에 있다.

| 슬롯 | 무엇 |
|---|---|
| `aliases` | 다른 이름. 규정 약칭, 법령 통칭, 부서 예전 이름 |
| `description` | 짧은 설명. 목록에 뿌릴 한 줄 |
| `sources` | 출처와 근거. 이 도메인에서는 사실상 필수다 |
| `tags` | 자유 분류 |
| `confidence` | low / medium / high |
| `updated` | 마지막 갱신 (GUIDE §6 이 bump) |

`aliases` 가 이 도메인에서 특히 값이 있다. 같은 규정을 부르는 이름이 부서마다 다르고
법령은 약칭으로 유통된다. 여기 안 적으면 같은 것에 노트가 둘 생긴다.

`sources` 를 비우지 않는다. 컴플라이언스 기록의 값은 근거에 있고, 근거 없는 상태는
감사에서 그대로 지적으로 돌아온다([[compliance-actions]]).

## 값 타입이 들어가는 자리

`cadence` 와 `reviewCycle` 은 문자열이 아니라 Cadence 값 타입이라 세 줄로 펼쳐 둔다.

```yaml
cadence:
  kind:
  anchor:
  graceDays:
```

한 줄로 접어 `cadence: quarterly` 라고 쓰지 않는다. 기준점과 유예 기간이 없으면 다음
기한을 산정할 수 없고, 기한을 산정할 수 없으면 [[compliance-lint]] 의 실질 점검이
돌지 않는다.

## 새 타입을 추가하면

`templates/<타입>.md.tpl` 을 만들고 위 수록 목록에 한 줄 추가한다. 절차는
[[compliance-object-types]] 의 "타입 추가: 프리셋 고유 델타" 5번이다.
