---
type: concept
scheme: context-protocol
pref_label_ko: 스토리지 백엔드
pref_label_en: Storage backend
broader: "[[context-workspace]]"
related:
definition: 워크스페이스 루트(WS)가 실제로 어디에 놓이는가에 대한 선택지. 클라우드 마운트와 로컬 디렉토리는 서로 다른 능력 집합을 갖고, 프로토콜 코어는 그 차이를 프로파일 하나로만 흡수한다.
---

# 스토리지 백엔드

프로토콜 6.0 부터 WS 는 구글 드라이브 동기화 폴더로 고정되지 않는다. WS 는
**백엔드 프로파일 하나를 고른 결과**이고, 코어 규범(레이어 모델, 조회/쓰기
프로토콜, 온톨로지, 능동 축적)은 어느 백엔드에서도 글자 그대로 같다.

이 분리가 가능한 이유는 5.0 시점에 이미 마운트 함정을 두 층으로 갈라 놓았기
때문이다. Layer A(샌드박스 프록시 마운트)는 백엔드와 무관하고, Layer B(클라우드
FUSE 의 지연 하이드레이션)만 백엔드에 달려 있다. 6.0 은 Layer B 를 프로파일로 치환한
것뿐이다. Layer A 는 7.x 에서 상수로 취급했으나 8.0 에서 하네스 능력 `proxy_mount` 로
옮겼다([[agent-harness]]).

## 프로파일이 선언하는 능력

프로파일 파일은 `_context-protocol/backends/<backend_id>.md` 하나다. 아래 아홉 개 키의 값이 코어의
어느 규칙을 켜고 끄는지가 계약의 전부다. 8.3 에서 아홉째 키 `vcs` 가 들어왔다. 8.2 까지의 프로파일과
폴백은 `vcs: none` 이라 동작이 그대로다.

| 능력 키 | 값 | 좌우하는 코어 규칙 |
|---|---|---|
| `sync_scope` | multi-pc / single-pc | GUIDE §0 존재 이유, §2 의 L0 대 L1 구분 강도 |
| `mount_root` | yes / no | GUIDE §4.9 MOUNT_ROOT + REL 분해 수행 여부 |
| `lazy_hydration` | yes / no | GUIDE §3-A 빈 결과 해석, §4.1, §4.2, §5 의 호스트 툴 강제 |
| `native_doc_stubs` | 확장자 목록 / none | GUIDE §4.6 |
| `symlink_registered` | yes / no | GUIDE §10 심링크 금지의 첫째 근거 |
| `dual_root` | 두 루트의 매핑 서술 / none | GUIDE §2 의 L1a public 과 L1b private |
| `connector` | 커넥터 id / none | GUIDE §4.6, §5 의 비-DC 예외 |
| `sync_lag` | yes / no | GUIDE §6 동시성 충돌 처리 |
| `vcs` | none / git | GUIDE §6 의 쓰기 단계를 감싸는 세션 절차(받기, 커밋, 반영 모드)가 있는가 |

Layer A 는 이 표에 없다. 백엔드 능력이 아니라 하네스 능력(`proxy_mount`,
[[agent-harness]])이기 때문이다. `proxy_mount: yes` 인 하네스(Cowork)에서는 연결된
폴더가 백엔드와 무관하게 프록시 마운트를 지나므로 delete, atomic rename, lockfile 제거
금지(GUIDE §4.5)가 켜져 있다. 순수 로컬 디렉토리도 예외가 아니다. 여기서 "로컬이니까
git 을 그냥 돌려도 되겠지" 로 새는 실수가 나온다. 백엔드가 이 값을 끄지 못한다는 점은
7.x 와 같다.

## 지금 있는 프로파일

| backend_id | 프로파일 | 상태 |
|---|---|---|
| `gdrive` | [[gdrive]] | 지원. 5.x 까지의 기본값이자 유일한 실측 대상 |
| `local` | [[local]] | 지원. 단일 PC 전제 |
| `git` | [[git]] | 선택(8.3). 동기화 폴더 밖의 git clone. 경로로 추론하지 않고 사용자가 고를 때만 쓴다 |
| `onedrive` | 없음 | 예약. 폴백 규칙 적용 |
| `dropbox` | 없음 | 예약. 폴백 규칙 적용 |

## 백엔드 판별

세션 시작에 정확히 한 번 판별하고, 그 결과를 세션 내내 쓴다.

근거는 셋이고 순위가 있다.

| 순위 | 근거 | 위치 |
|---|---|---|
| 1 | 사용자 선언 | `CONTEXT.md` frontmatter 의 `ws_backend` 와 `ws_backend_source: user` |
| 2 | 추론 기록 | `ws_backend` 와 `ws_backend_source: inferred`. source 줄이 없는 6.4 이전 기록도 여기 든다 |
| 3 | 라이브 추론 | 연결된 폴더의 절대경로 문자열(아래 표) |

1. `ws_backend_source: user` 면 그 값을 쓴다. 라이브 추론과 달라도 덮어쓰지 않는다.
   다르면 경로가 무엇을 가리키는지 사용자에게 한 번 말하고 바꿀지 묻는다. 답을
   받기 전까지 선언값을 유지한다.
2. 기록이 `inferred` 이거나 source 줄이 없으면 라이브 추론이 이긴다. 어긋남은
   워크스페이스가 옮겨졌거나 복사됐다는 뜻이므로 기록을 갱신하고 보고한다. 이때는
   멈추지 않는다. `ws_rel_path`(GUIDE §4.9)와 같은 철학이다.
3. 기록이 없어 추론으로 정했으면 `ws_backend_source: inferred` 를 함께 적어 다음
   세션이 다시 추측하지 않게 한다.
4. 판별된 id 에 프로파일 파일이 없으면 폴백 규칙(아래)을 적용하고, 미검증임을
   사용자에게 한 줄로 알린다.

설치기는 백엔드를 사용자에게 묻는다. 추론값은 그 질문의 추천 선택지로만 쓰고, 답은
`user` 로 기록한다.

### 추론 입력은 연결된 경로 문자열 하나다

추론은 연결된 폴더의 절대경로 문자열만 읽는다. 아래처럼 호스트를 조사해서 얻은 사실은
판별에 쓰지 않는다.

- 홈 디렉토리나 `~/Library/CloudStorage/` 를 나열해 설치된 동기화 클라이언트를 확인하는 것
- `OneDrive`, `OneDriveCommercial` 같은 환경변수, 실행 중인 프로세스, 설치된 앱 목록
- 같은 PC 에 있는 다른 워크스페이스의 `ws_backend`

PC 에 OneDrive 가 깔려 있다는 사실은 WS 의 위치와 무관하다. 이 조사로 백엔드를 정한
세션이 사용자가 `local` 을 고른 워크스페이스에 `onedrive` 를 기록했고, 6.4 가 그
자리를 막았다.

경로 모양 추론표:

| 신호 | backend_id |
|---|---|
| 드라이브 셀렉터 세그먼트(`My Drive`, `Shared drives`, `내 드라이브`, `공유 드라이브` 및 그 밖의 현지화 표기)가 **마운트 루트 바로 아래에** 있음. 또는 macOS `CloudStorage/GoogleDrive-<account>`. 또는 Windows File Stream 드라이브 레터 | `gdrive` |
| `CloudStorage/OneDrive-*`, `OneDrive - <org>`, 사용자 홈 바로 아래의 `OneDrive` 세그먼트(Windows 알려진 폴더 이동 포함) | `onedrive` |
| 경로 상단에 `Dropbox` 세그먼트 | `dropbox` |
| 위 어디에도 안 걸림 | `local` |

`git` 은 이 표에 없다. 경로 모양으로도, `.git` 폴더가 있다는 사실로도 추론하지 않는다. 코드 저장소에
프로토콜을 설치하는 경우가 흔하고, 에이전트가 커밋해도 되는지는 사용자만 정할 수 있기 때문이다.
`git` 은 언제나 사용자 선언(`ws_backend_source: user`)으로만 기록된다. 판별 절차와 반영 모드는
[[git]] 에 있다.

셀렉터는 경로 아무 데나 있으면 되는 것이 아니라 마운트 루트 바로 아래여야 한다.
`~/backup/My Drive/ws` 처럼 사람이 그 이름으로 만든 평범한 폴더를 gdrive 로 오판하지
않기 위해서다.

추론은 신호일 뿐 증거가 못 된다. 로컬로 쓰려는 폴더가 동기화 폴더 하위에 놓여 있을 수
있고, 반대로 심볼릭 링크를 타고 들어와 클라우드 경로 모양이 사라질 수도 있다.
그래서 사용자가 답한 값이 늘 추론을 이긴다. 경로와 선언이 어긋나면 알리고 묻는 데까지가
세션의 몫이다.

## 프로파일이 없는 백엔드 폴백

`onedrive`, `dropbox` 처럼 예약만 된 id 로 판별되면 다음 보수적 값을 쓴다.

```
sync_scope: multi-pc
mount_root: no          (REL 분해를 시도하지 않고 연결 경로를 그대로 WS 로 쓴다)
lazy_hydration: yes     (안전한 쪽. 호스트 툴 강제를 유지)
native_doc_stubs: unknown
symlink_registered: no  (안전한 쪽. 심링크 금지 유지)
dual_root: none
connector: none
sync_lag: yes
vcs: none
```

보수적이라는 말은 "제약을 더 거는 쪽" 이라는 뜻이다. 미검증 백엔드에서 규칙을
느슨하게 잡으면 실패가 조용히 나고, 조여 잡으면 느려질 뿐이다.

## 새 백엔드를 추가할 때

1. `_context-protocol/backends/<backend_id>.md` 를 만든다. 위 아홉 개 능력 키를 전부 채우고,
   `yes`/`no` 로 갈리는 항목은 **무엇을 실측했는지**를 함께 적는다. 실측하지 않은
   값은 값이 아니라 추측이라고 표시한다.
2. GUIDE 는 건드리지 않는다. 코어가 프로파일을 참조하도록 이미 짜여 있으므로,
   백엔드 추가가 코어 개정을 요구한다면 그 지점이 곧 코어의 추상화 누수다.
3. `storage-backend.md` 의 프로파일 목록 표에 행을 추가한다.
4. `_project.md` 의 `suitability.subjects` 확인, action-log 엔트리. 구조 추가의 공통 의무다.

## 무엇을 백엔드 문제로 보지 말아야 하나

아래는 백엔드와 무관하다. 프로파일에 적지 않고, 백엔드가 바뀌었다는 이유로
다시 검토하지도 않는다.

- Layer A 의 delete / atomic rename 금지 (GUIDE §4.5). 하네스 능력이다
- macOS 의 NFC/NFD 경로 불일치 (GUIDE §4.4)
- LibreOffice 의 stale `.~lock` (GUIDE §4.3)
- 호스트 정책에 의한 Write/Edit 차단 (GUIDE §4.7)
- 레이어 모델과 조회 순서, 쓰기 프로토콜, 온톨로지, 능동 축적 전체
