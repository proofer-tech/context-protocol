# context-protocol

폴더 하나를 **에이전트의 장기기억이자 1차 정보원(SoT)** 으로 쓰는 워크스페이스 프로토콜.

에이전트와 나눈 대화는 세션이 끝나면 사라지고, 도구마다 기억이 따로 논다. 이 프로토콜은
기억을 도구 안이 아니라 **사용자가 가진 폴더**에 둔다. 폴더 구조가 곧 분류 체계가 되고,
메모리와 액션 로그가 세션과 PC 와 도구를 넘어 남는다. Claude Cowork, Claude Code, Codex,
Cursor, Google Antigravity, Grok Build 가 같은 폴더를 같은 규칙으로 연다.

- 최신 버전: [Releases](https://github.com/proofer-tech/context-protocol/releases) 참고
- 라이센스: [PolyForm Noncommercial 1.0.0](LICENSE). 소스는 공개하지만 **상업적 이용은 허용하지 않는다** (아래 [라이센스](#라이센스))

## 빠른 설치

설치는 사람이 파일을 복사하는 일이 아니다. 에이전트에게 설치 패키지를 건네면 에이전트가
설치기를 읽고 폴더를 꾸민다.

1. [Releases](https://github.com/proofer-tech/context-protocol/releases) 에서 가장 최신
   `context-protocol-<버전>.zip` 을 내려받는다. 같은 버전에 `-b2`, `-b3` 처럼 빌드 번호가
   붙은 파일이 여럿 있으면 **번호가 가장 큰 것**을 쓴다.
2. 워크스페이스로 쓸 폴더를 에이전트 도구로 연다.
   - Claude Cowork: 프로젝트에 폴더를 연결한다
   - Claude Code, Codex, Cursor, Antigravity, Grok Build: 그 폴더에서 에이전트를 실행한다
3. zip 을 대화에 첨부하거나 폴더 안에 넣고 이렇게 말한다.

   ```
   이 파일을 압축해제해서 설치해줘
   ```

4. 에이전트가 묻는 질문(백엔드 종류 등)에 답한다. Claude Cowork 처럼 프로젝트 지침을
   붙여넣는 층이 있는 도구라면 마지막에 출력되는 블록을 **프로젝트 설정 > 지침**에
   붙여넣는다. 나머지 도구는 붙여넣을 것이 없다.

이미 이 프로토콜을 쓰는 폴더라면 같은 방법으로 새 zip 을 건네면 된다. 에이전트가 기존 설치를
알아보고 덮어쓰지 않고 버전 차이만 적용한다.

도구별 차이, 설치 후 확인 항목, 막혔을 때의 대응은 [docs/설치-가이드.md](docs/설치-가이드.md) 에 있다.

## 설치하면 생기는 것

```
<워크스페이스>/
  CONTEXT.md            규칙 정본이자 세션 진입점. 백엔드 설정이 frontmatter 에 있다
  AGENTS.md             포털. Codex, Cursor 등이 스스로 읽고 CONTEXT.md 로 넘어간다
  CLAUDE.md             포털. Claude 계열이 스스로 읽고 CONTEXT.md 로 넘어간다
  _project.md           이 워크스페이스가 무엇인지 (다른 워크스페이스가 import 할 때 본다)
  memory/MEMORY.md      메모리 인덱스. 사용자 정체성, 선호, 피드백, 진행 상태만
  action-log/           날짜별 사건 기록 (YYYY-MM-DD.md)
  _context-protocol/    가이드, 온톨로지 규약, 백엔드와 하네스 프로파일, 도구
```

이후의 지식은 주제별 폴더로 쌓인다. 폴더 위치가 곧 "이것이 무엇인가" 에 대한 분류다.

## 지원 환경

**에이전트 도구 (하네스)**

| 도구 | 상태 |
|---|---|
| Claude Cowork | 지원 |
| Claude Code | 실측 통과 |
| Codex (CLI, ChatGPT Work 모드) | 실측 통과 |
| Cursor | 실측 통과 |
| Google Antigravity | 실측 통과 (agy CLI) |
| Grok Build | 실측 통과 (대화형) |
| 파일 첨부만 하는 대화형 제품 | 열람 모드 전용, 미검증. 기록이 쌓이지 않는다 |

목록에 없는 도구도 폴더에 파일을 쓸 수 있으면 `generic` 폴백으로 동작한다.

**저장 위치 (백엔드)**

| 백엔드 | 상태 |
|---|---|
| `gdrive` (구글 드라이브 동기화 폴더) | 실측 검증. 여러 PC 에서 같은 워크스페이스 |
| `local` (일반 로컬 디렉토리) | 지원. PC 한 대 전제 |
| `onedrive`, `dropbox` | 예약. 프로파일이 없어 폴백 규칙으로 동작 |

## 프리셋

주제별 온톨로지 묶음이다. 설치 패키지에 같이 들어 있지만 **설치 대상이 아니다.** 설치를
마친 뒤 이름을 대며 요청할 때만 적용된다.

```
personal rag 프리셋으로 세팅해줘
```

| 프리셋 | 무엇을 위한 것인가 |
|---|---|
| `personal-rag` | 한 사람을 디지털 트윈으로 표현하는 개인 지식그래프 |
| `team-ops` | 한 팀의 운영 지식. 중심 타입은 Decision |
| `창업` | 예비창업자와 초기창업기업의 사업 자료. 중심 타입은 가설 |
| `compliance` | 법령에서 사내 규정, 통제, 이행 증거까지의 사슬 |
| `product-ideation` | 프로젝트급 개념 하나를 축과 측면으로 분해하는 뼈대 |

프리셋 호출 계약은 [presets/preset-library.md](presets/preset-library.md).

## 저장소 구조

이 저장소는 프로토콜의 **정본**만 담는다. 설치 패키지(zip)는 저장소에 넣지 않고
GitHub Release 로만 배포한다.

```
_context-protocol/
  CONTEXT_GUIDE.md      레이어 모델, 하드 룰, 마운트 함정, 조회와 쓰기 프로토콜의 정본
  _ontology.md          구조 우선 온톨로지 규약, 쓰기 전 분해
  _schema/              concept-scheme (frontmatter 키 규약)
  _views/               인덱스와 무결성 린트 뷰
  _concepts.base        개념 노트 베이스 뷰
  backends/             백엔드 능력 계약과 프로파일 (gdrive, local)
  harnesses/            하네스 능력 계약과 프로파일 7종
  installers/           CONTEXT_SETUP.md (신규), CONTEXT_MIGRATE.md (기존 버전 올리기)
  tools/hwp2md.py       한글(hwp, hwpx) 문서 변환기
presets/                  주제별 온톨로지 프리셋 5종
package/README.md         zip 루트에 들어가는 README. 압축을 푼 에이전트가 가장 먼저 읽는다
scripts/build.sh          설치 패키지 빌드와 검증
docs/                     설치 가이드, 릴리스 절차
```

처음 읽는다면 이 순서가 빠르다.

1. [package/README.md](package/README.md) - 설치가 실제로 어떻게 진행되는가
2. [_context-protocol/CONTEXT_GUIDE.md](_context-protocol/CONTEXT_GUIDE.md) - 규범 전체
3. [_context-protocol/_ontology.md](_context-protocol/_ontology.md) - 폴더가 곧 온톨로지라는 방식
4. [_context-protocol/harnesses/agent-harness.md](_context-protocol/harnesses/agent-harness.md),
   [_context-protocol/backends/storage-backend.md](_context-protocol/backends/storage-backend.md) - 도구와 저장 위치를 흡수하는 방법

설치기 두 개는 가이드와 템플릿 전문을 자기 안에 블록으로 들고 있다. 정본을 고치면 설치기
블록도 같이 고쳐야 하고, `scripts/build.sh` 가 둘이 어긋나면 빌드를 멈춘다.

## 직접 빌드하기

```bash
scripts/build.sh        # dist/context-protocol-<버전>.zip
scripts/build.sh 2      # dist/context-protocol-<버전>-b2.zip
```

버전은 `CONTEXT_MIGRATE.md` 의 LATEST_VERSION 에서 읽는다. 스탬프 대조, 블록 대조, MANIFEST
생성, 압축 해제 후 `diff -r` 검증까지 한 번에 한다. 릴리스 절차는 [docs/릴리스.md](docs/릴리스.md).

## 라이센스

[PolyForm Noncommercial License 1.0.0](LICENSE). Copyright 2026 임한솔.

비상업 조건이 붙어 있으므로 OSI 기준의 "오픈소스" 가 아니라 **소스 공개(source-available)**
라이센스다. 요약하면 이렇다. 법적 효력은 [LICENSE](LICENSE) 원문에만 있다.

| 할 수 있다 | 할 수 없다 |
|---|---|
| 개인 워크스페이스에 설치해 쓰기 | 이 프로토콜이나 파생물을 판매하기 |
| 연구, 학습, 취미 프로젝트에 쓰기 | 유료 서비스나 컨설팅 상품에 넣어 제공하기 |
| 학교, 공공기관, 비영리 단체에서 쓰기 | 영리 기업의 업무에 쓰기 |
| 수정하고 비상업 조건으로 다시 배포하기 | Required Notice 줄을 지우고 배포하기 |

다시 배포할 때는 받은 사람도 같은 조건을 알 수 있도록 [LICENSE](LICENSE) 의 첫 줄
`Required Notice: Copyright 2026 임한솔 (...)` 을 그대로 함께 전달해야 한다.

상업적 이용이 필요하면 [이슈](https://github.com/proofer-tech/context-protocol/issues) 로 문의한다.
