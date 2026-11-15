---
type: document
backend_id: gdrive
title: Backend profile - Google Drive
---

# 백엔드 프로파일: Google Drive

구글 드라이브 동기화 폴더를 WS 로 쓴다. 5.x 까지 프로토콜의 유일한 전제였고,
지금도 유일하게 실측으로 검증된 백엔드다.

## 능력

| 능력 키 | 값 | 근거 |
|---|---|---|
| `sync_scope` | multi-pc | Drive 클라이언트가 모든 PC 로 동기화 |
| `mount_root` | yes | 마운트 루트가 PC/OS/계정마다 달라 REL 분해가 필요 |
| `lazy_hydration` | yes | 디렉토리 엔트리는 항상 로컬, 내용은 placeholder |
| `native_doc_stubs` | `.gdoc` `.gsheet` `.gslides` | 로컬 파일이 200 바이트 URL 스텁 |
| `symlink_registered` | no | 2026-08-18 실측 |
| `dual_root` | 공유 드라이브 = L1a public / 내 드라이브 = L1b private | |
| `connector` | google-drive | 네이티브 문서와 동기화 폴더 밖 항목 |
| `sync_lag` | yes | 다른 PC 의 최신본이 아직 로컬에 없을 수 있음 |
| `vcs` | none | git 으로 운용하려면 동기화 폴더 밖에 clone 하고 `git` 백엔드를 고른다 |

## WS 경로 분해 (mount_root: yes)

WS 경로는 **MOUNT_ROOT + REL** 두 조각이다. 둘 다 매 세션 런타임에 유도하므로
어떤 계정, 어떤 드라이브(내 드라이브든 공유 드라이브든), 어떤 폴더 위치, 어떤 OS
에서도 동작한다. 환경에 관한 어떤 값도 하드코딩하거나 저장값과 대조하지 않는다.

1. 이 세션의 작업 폴더로 연결된 절대경로에서 시작한다(환경이 제공한다).
2. MOUNT_ROOT: 그 경로 안에서 구글 드라이브 마운트 앵커를 알아본다. 드라이브
   셀렉터(`내 드라이브`, `공유 드라이브`, `My Drive`, `Shared drives` 및 현지화
   표기)가 놓인 계정/File Stream/드라이브 레터 루트까지가 MOUNT_ROOT 다. 특정
   계정명이나 드라이브명이 아니라 **모양**으로 알아본다.
3. REL = 연결된 절대경로 - MOUNT_ROOT. 이 절반이 이식 가능한 쪽이다. 모든 PC 에서
   동일하다. PC 마다 다른 부분이 정확히 MOUNT_ROOT 이고 그것을 뺐기 때문이다.
4. WS = MOUNT_ROOT + REL. 산문, 동기화되는 파일, 붙여넣는 지침에는 항상 워크스페이스
   루트 기준 상대경로만 쓴다. 조합된 절대경로는 살아 있는 세션만 들고 있는다.

`CONTEXT.md` frontmatter 의 `ws_rel_path` 는 유도된 REL 의 기록이다. 사람이 읽고
크로스프로젝트 발견에 쓰라고 두는 값이지 해석의 근거가 아니다. 기록과 유도값이
어긋나면 라이브 유도를 신뢰하고 기록을 갱신한다.

현지화 주의: 셀렉터 세그먼트는 UI 언어를 따른다. 한국어 UI 는 `공유 드라이브` /
`내 드라이브`, 영어 UI 는 `Shared drives` / `My Drive`. REL 을 매 세션 유도하므로
이 환경이 실제로 쓰는 표기가 자연히 실린다. 한쪽 철자를 가정하지 않는다.

## Layer B: 클라우드 전용 파일 (lazy_hydration: yes)

`~/Library/CloudStorage/...` 자체가 가상 파일시스템이다. 디렉토리 엔트리는 항상
로컬에 있지만 내용은 placeholder 일 수 있고 첫 접근에 하이드레이션된다. 여기서
아래가 따라 나온다.

- **샌드박스 셸의 빈 결과는 부재가 아니다.** grep/find/ls 가 못 찾은 것은 파일이
  없어서가 아니라 하이드레이션되지 않아서일 수 있다. "없다" 는 판정은 호스트측
  도구(DC `start_search`, 내장 Read/Grep/Glob)로만 내린다. GUIDE §3-A.
- **zip 기반 오피스 파일은 경로로 열지 않는다.** `zipfile.BadZipFile` 은 placeholder
  가 돌아왔다는 신호다. 바이트를 읽어 메모리에서 연다. `OSError: [Errno 35]
  Resource deadlock avoided` 는 일시적 마운트 락이니 한 번 재시도한다. GUIDE §4.2.
- **`shutil.copy` 를 마운트에서 쓰지 않는다.** 수동 read + write 로 복사한다.

## 네이티브 문서 스텁 (native_doc_stubs)

`.gdoc` / `.gsheet` / `.gslides` 는 로컬에 본문이 없다. 열면 URL 스텁이고 DC 로도
읽히지 않는다. 구글 드라이브 커넥터로 doc_id 를 통해 읽거나, 에이전트가 자주 읽어야
하는 문서라면 워크스페이스에 `.md` 사본을 둔다.

## 심링크 (symlink_registered: no)

마운트에서 `ln -s` 는 성공하고 로컬에서 읽히기까지 하지만, 그 링크의 Drive item-id
를 조회하면 링크가 아니라 **원본 파일의 id** 가 돌아온다. 생성 시각도 부모 폴더도
원본 것이다. 링크 자체가 업로드되지 않으므로 다른 PC 에는 그 파일이 존재하지
않는다. 멀티 PC 동기화가 이 워크스페이스의 존재 이유인데 심링크는 정확히 그
지점에서 무너진다. (2026-08-18 실측)

이것이 GUIDE §10 심링크 금지의 첫째 근거다. 나머지 두 근거(위치가 곧 분류 주장,
사본은 갈라진다)는 백엔드와 무관하므로 이 백엔드가 아니어도 금지는 유지된다.

## 두 루트 (dual_root)

- L1a public = 공유 드라이브. 검증된, 팀에 공유 가능한 내용.
- L1b private = 내 드라이브. 민감 정보와 진행 중 의사결정.

공유 드라이브 덕분에 사람과 에이전트가 같은 SoT 를 읽는다. private 의 존재 자체가
민감할 수 있으므로 public 에서 private 으로 가는 포인터를 남기지 않는다.

## 동기화 지연 (sync_lag: yes)

다른 PC 의 최신본이 아직 로컬에 내려오지 않았을 수 있다. 쓰기 전에 반드시 읽고,
`updated` 를 올리고, 읽은 날짜와 쓰는 날짜가 다르면 다시 읽어 병합한다. 충돌이
보이면 덮어쓰지 말고 사용자에게 보고한다. GUIDE §6.

## 데몬 프로세스의 dataless 거부 (lazy_hydration: yes, macOS)

관측 (2026-09-22 첫 보고, 2026-10-06 메커니즘 확인). 한 맥미니에서 launchd 데몬으로 띄운
에이전트 런타임이 이 프로파일의 파일을 읽지 못했다. `cat`, `python3 open().read()`, `cp`,
`osascript do shell script "cat ..."`, Desktop Commander `read_file` 이 전부 `Resource deadlock
avoided`(macOS errno 11, EDEADLK. DC 에서는 `Unknown system error -11`)로 실패했고 재시도로
풀리지 않았다. dataless 디렉터리의 목록(`ls`, `os.listdir`)도 같은 에러를 낸다. `xattr -l` 은
메타데이터만 돌려주고 `mdls`, `brctl download`(iCloud 전용)는 쓸모가 없었다. 같은 폴더를
마운트한 다른 기기에는 dataless 파일이 아예 없어서 증상도 없었다.

원인. macOS 는 프로세스마다 dataless 파일 materialize 정책을 둔다(`setiopolicy_np`,
`IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES`). man 페이지 기준으로 시스템 기본값은 OFF 이고 새
프로세스는 부모의 정책을 상속한다. OFF 인 프로세스가 dataless 파일을 열면 다운로드 요청 대신
EDEADLK 가 돌아온다. 데스크톱 앱 아래에서 뜬 프로세스는 ON 을 물려받는다. launchd 데몬으로 뜬
런타임은 OFF 로 시작하고, 그 아래 셸과 Claude Code 와 DC MCP 서버가 전부 OFF 를 물려받는다.
GUIDE §4.1 의 "DC 는 접근 시 하이드레이션한다"는 전제가 여기서 깨진다.

검증 (2026-10-06, 다른 맥). 상속값이 ON 인 DC 프로세스에서 정책만 OFF 로 바꾸자 `open()` 과
자식 `cat` 이 EDEADLK 로 실패했고 파일은 dataless 로 남았다. 부모가 OFF 여도 ON 으로 바꾼 뒤
exec 한 `cat` 은 정상으로 읽었다. NSFileCoordinator 읽기는 OFF 프로세스에서도 성공했다. 처음
증상이 난 맥미니의 데몬 세션에서도 아래 진단 값이 1(OFF)로 나왔고, 그 세션은 막힌 파일을 fpcoord 로
전부 읽었다. 값이 0(시스템 기본값)이 아니라 1 이므로 상속 경로 어딘가에서 OFF 가 명시적으로 걸린
것이다. launchd 자신일 수도 있고 어느 프로세스인지는 아직 모른다.

진단. 의심되는 세션에서 한 줄 돌린다. 2 면 ON 이고, 0(시스템 기본값) 이나 1 이면 OFF 다.

```bash
python3 -c "import ctypes; print(ctypes.CDLL(None).getiopolicy_np(3, 0))"
```

대응 순서.

1. 근본 대응. 에이전트 런타임을 띄우는 지점에서 정책을 ON 으로 바꾸고 exec 한다. 자식 전체가
   상속하므로 DC, 셸, 스크립트를 따로 고칠 필요가 없다. launchd plist 의 `ProgramArguments`
   앞에 끼우는 식이다.

   ```bash
   # 정책을 ON 으로 바꾸고 나머지 인자를 그대로 실행한다
   python3 -c 'import ctypes, os, sys; ctypes.CDLL(None).setiopolicy_np(3, 0, 2); os.execvp(sys.argv[1], sys.argv[1:])' <원래 명령> <인자...>
   ```

2. 단건 우회. 런타임을 못 고치는 세션은 NSFileCoordinator 로 파일 하나씩 읽는다. 읽기를
   fileproviderd 가 대신 materialize 하므로 호출자 정책을 타지 않는다. 아래 소스를 마운트 밖에
   빌드해 두고 쓴다(`swiftc -O fpcoord.swift -o /tmp/fpcoord`). 실패는 stderr 와 exit 1 로
   나오므로 빈 출력은 정말 빈 파일이다. 에러를 삼키고 빈 문자열을 내는 버전은 쓰지 않는다.
   "빈 결과는 부재가 아니다"(GUIDE §3-A)를 도구가 거꾸로 만들기 때문이다.

   ```swift
   // fpcoord read <path>  -> 원본 바이트를 stdout 으로
   // fpcoord list <dir>   -> 한 줄에 이름 하나
   import Foundation
   func fail(_ m: String) -> Never { FileHandle.standardError.write((m + "\n").data(using: .utf8)!); exit(1) }
   let a = CommandLine.arguments
   guard a.count == 3, a[1] == "read" || a[1] == "list" else { fail("usage: fpcoord read|list <path>") }
   let url = URL(fileURLWithPath: a[2])
   var coordError: NSError?
   var inner: Error?
   var out = Data()
   var names: [String] = []
   NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordError) { u in
       do {
           if a[1] == "read" { out = try Data(contentsOf: u) }
           else { names = try FileManager.default.contentsOfDirectory(atPath: u.path).sorted() }
       } catch { inner = error }
   }
   if let e = coordError { fail("coordinate failed: \(e.localizedDescription)") }
   if let e = inner { fail("\(a[1]) failed: \(e.localizedDescription)") }
   if a[1] == "read" { FileHandle.standardOutput.write(out) } else { for n in names { print(n) } }
   ```

3. GUI 폴백. GUI 세션이 있고 swift 를 못 쓸 때만 `open -g -a TextEdit "<파일>"` 로 앱을 통해 연
   다음 3~5초 뒤 다시 읽는다. 앱이 실제로 뜨는 부작용이 있다.

한 번 materialize 된 파일은 dataless 플래그(`ls -lO`)가 사라져 이후 모든 도구로 읽힌다. 파일
단위 부수 효과일 뿐이고 사전 다운로드 수단으로 쓰지 않는다.

방침 (사용자 결정, 2026-10-06). 해결책으로 Drive 앱을 미러링으로 바꾸거나 세션 시작 때 폴더
전체를 미리 materialize 하지 않는다. 스트리밍을 유지하고 필요한 파일만 접근 시점에 받는다.
에이전트가 먼저 그쪽을 제안하지도 않는다. 1번 래퍼는 이 방침 안에 있다. 데몬 프로세스를 데스크톱
앱 아래 프로세스와 같은 동작으로 돌려놓을 뿐이다.

OS 범위. 이 절의 원인과 대응은 macOS FileProvider 전용이다. Windows 의 Drive for desktop 은 구조가
다르다(실측 2026-10-06, Windows 11 Home 빌드 26300, Drive 131.0.2.0). Cloud Filter API(`cldflt.sys`)의
싱크 루트를 등록하지 않고, 자체 파일시스템 드라이버(`googledrivefs*.sys`)로 드라이브 문자(`G:`) 볼륨을
따로 올린다. 그 볼륨은 `fsutil fsinfo volumeinfo` 에서 `FAT32` 로 보이고, 클라우드 전용 파일에도
Offline, RecallOnDataAccess, 리파스 포인트 같은 플레이스홀더 표식이 없다. 같은 기계의 OneDrive 파일에는
그 표식이 정상으로 붙어 있었다. 그래서 하이드레이션 상태는 파일 속성으로 알 수 없고 Drive 의 로컬
`content_cache` 에서만 보인다. 사용자 로그온 세션의 스케줄 작업으로 뜬 Multica 런타임에서 `Get-Content`,
`cmd /c type`, node 읽기가 클라우드 전용 파일을 막힘 없이 읽었다(첫 읽기 약 1.1~1.3초, 이후 수십 ms).
Windows 에는 이 절의 우회가 필요 없고 `CfHydratePlaceholder` 같은 Cloud Filter 호출도 해당하지 않는다.
`fltmc instances -v G:` 로 필터 부착을 직접 보는 것은 관리자 권한이 필요해 못 했지만, 볼륨 능력 목록이
같은 자리를 메운다. `fsutil fsinfo volumeinfo G:` 가 `Supports Unicode in filenames` 와 `Supports Remote
Storage` 만 내고 Reparse Points 와 Sparse Files 는 내지 않는다. Cloud Files API 플레이스홀더는 그 두 기능
위에 세워지므로(같은 기계의 OneDrive 파일이 `0x9000401a` 리파스 태그와 `SPARSE_FILE` 속성을 그대로 보여
준다) 둘 다 없는 볼륨에는 플레이스홀더가 존재할 수 없다(2026-10-06 교차 확인, Multica `PRF-579`).
미검증으로 남은 것은 로그온 세션 밖(세션 0 서비스)에서 도는 런타임 하나다.

## 변경 파일 훑기는 POSIX find 가 아니라 디렉터리 열거로 한다 (Windows, 2026-10-13 실측)

마운트 전체에서 "언제 바뀐 파일" 을 찾을 때 Git Bash 의 `find ... -newermt` 나 `-printf '%T+'` 를 쓰면
파일마다 `stat()` 이 한 번씩 나간다. 이 볼륨에서 그 한 번이 0.15초 안팎이라 **15,929 파일에 60분을 넘기고도
안 끝났다.** 같은 트리에서 이름만 뽑는 `find -type f` 는 29초다 - 느린 것은 순회가 아니라 건별 stat 이다.

Windows 의 디렉터리 열거(`FindFirstFile` / `FindNextFile`)는 타임스탬프를 엔트리와 함께 돌려주므로
건별 stat 이 아예 없다. PowerShell 로 같은 일을 하면 **10초**다.

```powershell
$items = Get-ChildItem -LiteralPath 'G:\공유 드라이브\<workspace>' -Recurse -File -Force -ErrorAction SilentlyContinue
$items | Where-Object { $_.LastWriteTime -ge (Get-Date '2026-10-12 00:00:00') }
```

- 경로 목록만 필요하면 `find` 로 뽑아도 된다. **시각이 필요한 순간 도구를 바꾼다.**
- 같은 이유로 `find -newer <파일>`, `ls -l` 재귀, `stat` 루프도 전부 느리다.
- macOS 쪽은 재지 않았다. 이 줄은 Windows 드라이브 문자 마운트 실측이다(Multica `PRF-710`).

## 증상 표 (이 백엔드 고유분)

| 증상 | 원인 | 대응 |
|---|---|---|
| 샌드박스 grep/ls 가 빈 결과 | 클라우드 전용 파일이 안 보임 | DC start_search / 내장 Grep |
| Errno 35 deadlock | 일시적 마운트 락 | 재시도, 또는 io.BytesIO. 재시도로 안 풀리면 아래 행을 의심한다(Linux 의 35 와 macOS 의 11 은 같은 EDEADLK, 미검증) |
| BadZipFile | placeholder / 동시 접근 | io.BytesIO 로드 |
| shutil.copy 실패 | 마운트의 mmap/sendfile | 수동 read + write |
| 파일이 URL 로 열림 | 네이티브 구글 문서 스텁 | Drive 커넥터 export |
| `Resource deadlock avoided`(macOS errno 11, DC 는 -11)가 호스트측 도구에서도 재시도 후 지속 | 프로세스의 dataless materialize 정책이 OFF (launchd 데몬 계열) | 진단 한 줄, 런타임 래퍼로 ON, 안 되면 fpcoord 단건 읽기. "데몬 프로세스의 dataless 거부" 절 |
| `find -newermt` 가 몇십 분째 안 끝남 | 건별 `stat()` 이 마운트에서 0.15초 안팎 | PowerShell `Get-ChildItem -Recurse -File` 로 바꾼다(디렉터리 열거가 타임스탬프를 같이 준다). 위 절 참조 |

Layer A 유래 증상(delete 불가, git lock 제거 불가)은 이 표가 아니라 GUIDE §4.5 다.

## git 저장소를 두지 않는다

하네스가 `proxy_mount: no` 라서 삭제와 git 이 기술적으로 되더라도, 이 백엔드의 워크스페이스
안에서 `git init` 을 하거나 저장소를 운용하지 않는다. 동기화 클라이언트가 `.git` 내부 파일을
여러 PC 사이에서 따로 올리고 내리면서 저장소가 깨진다. 코드 저장소는 동기화 폴더 밖 로컬에
두고 결과물만 워크스페이스로 복사한다. 워크스페이스 자체를 git 으로 운용하고 싶으면 동기화 폴더 밖에
clone 하고 `git` 백엔드(8.3)를 고른다. 이 규칙은 하네스가 아니라 백엔드(`sync_scope: multi-pc`)가
정한다. 2026-10-25 실측에서 Claude Code 는 이 점을 짚었고 Grok Build 는 `proxy_mount: no` 만
보고 git 을 허용한다고 답했다. 그래서 하네스 프로파일의 주의가 아니라 이 프로파일의 규칙으로 둔다.
백엔드를 바꿔도 사라지지 않는다.
