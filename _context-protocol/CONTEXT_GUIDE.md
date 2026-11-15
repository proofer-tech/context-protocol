---
type: document
subject:
  - "[[context-workspace]]"
---

# A Synced Workspace as Agent Context

> Project-agnostic guide for running a workspace folder as the agent's long-term
> memory and primary SoT.
> Prereq: an agent harness that can read and write the workspace folder. The
> tool that does host-side file work is a harness capability (§0-B); on Claude
> Cowork it is the Desktop Commander (DC) MCP plugin.
> Guide version: 8.2 (8.2 adds a check level, 직접 확인 or 보고됨, to every
> action-log entry, §12.3. 8.1 makes `memory/MEMORY.md` a memory-layer router
> and drops every hand-kept file list, §6. 8.0 makes the core harness-neutral: CONTEXT.md is the
> rule canon, AGENTS.md and CLAUDE.md are portals into it, and tool names, agent
> memory and the sandbox proxy mount move into harness profiles, §0-B. Earlier:
> backend profiles: WS is a cloud mount OR a plain local
> directory, and the core is written against a capability profile instead of
> Google Drive; protocol renamed to context-protocol; instruction-layer inversion
> from 5.0 kept: pasted block = bootstrap pointer, the root entry file = rule canon
(CLAUDE.md until 7.3, CONTEXT.md from 8.0).
> 6.1 corrects installer defects found by simulating the 6.0 documents; the
> guide's own rules are unchanged. 6.4 ranks a user-declared backend above path
> inference and bars host probing for sync clients, §0-A. 7.0 moves CONTEXT_*.md
> and backends/ into _context-protocol/, §8 and §10. 7.1 makes knowledge writes
> decompose before they land: one topic per file, born-decomposed project
> concepts, provenance sections, raw-record marker, §12.2. 7.2 notes that host-side
> hydration depends on the calling process, which a daemon-launched runtime can
> lack, §4.1 and §5. 7.3 ties curated notes to their originals with `grounded_on`
> and versions to each other with `supersedes`, and promotes a correction to a
> rule only when it repeats, §3, §10, §12.1).

## 0. Why a workspace

- Curated knowledge outlives the session only if it lives in files the next
  session can find.
- An agent's own memory (Claude auto-memory, Codex or Grok memories, a chat
  product's account memory) is bound to one host or account and one harness, so
  another harness opening the same workspace never sees it. On a cloud-mount backend it is also lost
  across PCs, so only the workspace is real long-term memory.
- One folder that humans and agents both read is a single SoT, not two.

Two things make a connected workspace folder unlike a normal directory, and they
are separate concerns. Keep them separate.

- **Layer A - the sandbox proxy mount (proxy_mount: yes).** A harness that runs
  the agent in a sandbox (Claude Cowork today) re-exposes every connected folder
  through a FUSE proxy that denies unlink and rename-over, cloud or local alike.
  It belongs to the harness, not the backend: a harness that works on the host
  filesystem (Claude Code, Codex, Cursor) has no such layer. See §0-B and §4.5.
- **Layer B - the backend's own filesystem behavior.** Lazy hydration, native
  document stubs, symlink registration, sync lag. These vary by backend and are
  declared in a backend profile, not assumed here. See §0-A.

## 0-A. Backend profile

WS is not a fixed kind of folder. It is whichever backend this workspace chose:
a cloud mount (Google Drive today, OneDrive / Dropbox reserved) or a plain local
directory. The core in this guide is identical on every backend; only the
profile differs.

A profile declares eight capabilities: `sync_scope`, `mount_root`,
`lazy_hydration`, `native_doc_stubs`, `symlink_registered`, `dual_root`,
`connector`, `sync_lag`. Each one switches a specific core rule on or off. The
capability contract, the detection procedure, the path-shape inference table,
and the fallback for unprofiled backends all live in
`_context-protocol/backends/storage-backend.md`.

Session obligation: resolve the backend once, at session start, before any rule
that depends on it fires.

1. Read `ws_backend` and `ws_backend_source` from `CONTEXT.md` frontmatter. If
   `ws_backend` is absent, infer it from the workspace root path shape (the root
   is resolved by the harness step, §0-B) and record it
   with `ws_backend_source: inferred`.
2. Read `_context-protocol/backends/<ws_backend>.md`. Read only that one; other profiles describe
   other environments and their pitfalls do not apply here.
3. `ws_backend_source: user` marks the user's own choice, and it outranks live
   inference. Never overwrite it. If live inference disagrees, tell the user once
   what the path suggests and ask whether to change it; until they answer, keep
   the declared value. A recorded value that is `inferred`, or has no source
   line, yields to live inference: refresh the record and say so. Never block on
   that mismatch.
4. Inference reads the connected folder's absolute path string and nothing
   else. Do not probe the host for sync clients: no listing of the home
   directory or `~/Library/CloudStorage/`, no `OneDrive*` environment variables,
   processes, installed apps, or other workspaces' records. A sync client being
   installed on this PC says nothing about where WS lives, and deciding from it
   is how a workspace the user set to `local` got recorded as `onedrive` (6.4).

Everywhere below, a rule that depends on a capability names it inline, like
"(lazy_hydration: yes)". If the profile says otherwise, the rule is off.

## 0-B. Harness profile

The harness is the program that runs the agent and opens WS: Claude Cowork,
Claude Code, Codex, Cursor, Google Antigravity, Grok Build, or a chat product
where files are only uploaded. Harnesses differ in which file they load on
their own, which tool reaches host files, whether a sandbox mount sits in
between, and whether they keep a memory of their own. The core in this guide
names capabilities, never one harness's tools; a harness profile binds each
capability to the real tool.

A profile declares nine capabilities: `entry_file`, `import_syntax`,
`host_file_tool`, `proxy_mount`, `agent_memory`, `fs_write`, `ask_tool`,
`deliver_file`, `bootstrap_block`. The contract, detection, the nested-workspace
rule and the `generic` fallback live in
`_context-protocol/harnesses/agent-harness.md`.

Entry files. `CONTEXT.md` at the root is the rule canon and the session entry.
`AGENTS.md` and `CLAUDE.md` at the root are portals: harnesses load them on
their own, and each holds only a pointer to CONTEXT.md and the nested-workspace
rule. A rule written into a portal forks the canon; move it into CONTEXT.md.

Session obligation, before the backend (§0-A), because the backend's input path
depends on the harness:

1. Identify the harness from your own runtime and tool list. Do not infer it
   from which portal you were handed: several harnesses read AGENTS.md, and some
   read both portals.
2. Read `_context-protocol/harnesses/<harness_id>.md`, and only that one. With no
   matching profile, use the `generic` fallback and tell the user once that this
   harness is unverified.
3. Keep the result for this session only; never record it in the workspace. The
   same workspace is opened by different harnesses on different days.
4. The workspace root is the folder the harness connected (Cowork), or the
   folder of the portal nearest to the working directory. That path is the
   input to §0-A inference. An outer workspace whose portal was also loaded is an
   import candidate (§11), not WS.

A rule that depends on a harness capability names it inline the same way, like
"(proxy_mount: yes)".

## 1. Mental model: two kinds of truth

- Curated project context (domain knowledge, policies, ops guides, decisions):
  SoT = the workspace (L1). Answer from L1; do not re-query live sources.
- Volatile live facts (today's messages, live sheet values, current state):
  SoT = live sources (L3). Workspace copies are point-in-time snapshots.

Forbidden anti-pattern: skipping the workspace and querying live sources first
"because the workspace is just a snapshot". Go to L3 only for volatile facts,
or after L1 misses.

## 2. Context layers

```
L0 agent memory    the harness's own memory (agent_memory, §0-B); host- or
                   account-bound, unsynced; secondary cache.
                   Thin pointers to L1 only. Never store bodies here.
L1 workspace       the connected workspace folder; primary SoT.
  L1a public       verified, team-shareable.
  L1b private      sensitive info, in-flight decisions (optional).
L2 cache           <ws>/cache/<topic>/YYYY-MM-DD.md (TTL 1 day)
L3 live sources    Slack, live sheets/docs, GitHub. SoT for volatile facts.
ontology overlay   structure-first: folders = concepts, md originals carry
                   subject in frontmatter. Helpers grouped under
                   <ws>/_context-protocol/ (_concepts, _schema, _views; sec 10).
```

What L1a and L1b map to is a backend question (`dual_root`): two drives on a
cloud backend, two directories on a local one, or a single root when the split
is not needed. What does not vary is the routing rule.

Rules:
1. Curated context: answer from L1.
2. Volatile facts: L3, but only after the §3 lookup order.
3. On a multi-PC backend (`sync_scope: multi-pc`), anything needed on another PC
   goes to L1 and L0 holds pointers only. On `single-pc`, L0 is still the wrong
   place, because it is scoped to the agent host and not to the workspace.
4. If public/private split: sensitive info only in private. No pointers to it
   from public (its existence may itself be sensitive). On a local backend the
   filesystem does not enforce this; the rule still holds.

## 3. Lookup protocol

Order: L0 -> L1a -> L1b -> L2 -> L3. Advance only on miss.

1. On session start, read workspace `CONTEXT.md` (the portals AGENTS.md and
   CLAUDE.md lead here) and the `memory/MEMORY.md` index; follow index hits into
   bodies. Resolve the harness (§0-B) and then the backend profile (§0-A) in the
   same step.
2. For domain work, also read that domain folder's ops guide.
3. An L2 cache is valid only if its filename date == today; else re-query L3
   and refresh.
4. Verify paths/IDs found in memory still exist before using them.
5. Version chains: when the hit is a document that another document
   `supersedes`, follow the chain to its newest version, answer from it, and
   name the version. Never pick the current version by modified time or by a
   filename word such as "final"; sync and copies move timestamps, and people
   decide which version is final. Superseded versions stay unedited.
6. A curated note that lists `grounded_on` originals answers lookups as usual.
   When integrity-lint shows it under the grounding-drift signal, open the
   changed original before relying on the note, then fix the note or record the
   check in `grounded_checked` (§10).

### 3-A. Hard rules: "L0 miss != not in memory"

Whatever memory the harness injects into the session (an auto-memory index,
saved memories) is only L0. Before answering "not in memory / never seen it" or
jumping to L3, you MUST search L1 with the harness's host-side search (§5; DC
`start_search` with searchType=content on Cowork).

- L1 hit -> that body is SoT. Answer from it.
- Only after a confirmed L1 miss may you say "not in memory", then query L3.
- L0-miss -> straight to L3 = hitting the most expensive, least stable layer
  first. Forbidden.
- (lazy_hydration: yes) A sandbox-shell grep/find/ls returning empty is NOT
  "absent": unhydrated files are invisible to the sandbox. Search only with
  host-side tools (`host_file_tool`, §5). On a backend
  with `lazy_hydration: no` an empty sandbox result does mean absent, but the
  host-side tools stay the default for the reasons in §5.

## 4. Mount and filesystem pitfalls

§4.5 is Layer A and applies whenever the harness has `proxy_mount: yes`; no
backend switches it off. §4.3, §4.4, §4.7 and the §4.8 core table
are OS or host-policy issues and are also backend-independent, as is §4.10
(HWP/HWPX documents). §4.9 is split:
"never hardcode an absolute path" holds everywhere, only the MOUNT_ROOT + REL
decomposition is gated on `mount_root`. The rest is capability-gated; the
backend profile carries the measured detail and its own symptom table.

### 4.1 Unhydrated files: entry exists, content doesn't (lazy_hydration: yes)

Symptom: sandbox bash grep/find/cat misses a file that clearly exists ->
false "file not found".
Cause: the sandbox sees only locally hydrated files.
Fix: host-side tools (`host_file_tool`, §5). On Cowork, DC `start_search` /
`read_file` hydrate on access and built-in Read/Grep/Glob also run host-side. A
harness that works on the host filesystem has no separate sandbox, so its own
file tools are the host side.
That holds only when the host process is allowed to materialize cloud files.
On macOS an agent runtime launched as a background daemon may not be (the
per-process policy is inherited by every child, DC included), and then every
host-side tool fails the same way with `Resource deadlock avoided`. That is a
process setting, not a missing file and not a transient lock. The backend
profile carries the diagnosis and the fix.

### 4.2 Resource deadlock / BadZipFile, zip-based Office files (lazy_hydration: yes)

- `OSError: [Errno 35] Resource deadlock avoided`: transient mount lock
  during read/copy.
- `zipfile.BadZipFile`: placeholder returned, or concurrent access.

Fix: never load xlsx/docx/pptx by path. Always via memory:

```python
import io
from openpyxl import load_workbook
with open(ws_path, 'rb') as f:
    data = f.read()          # retry once on failure
wb = load_workbook(io.BytesIO(data))
```

Save in two steps: write to a local tmp path, then copy manually with
`open('rb').read()` + `open('wb').write()`. Never shutil.copy on the mount.

### 4.3 Stale .~lock files (backend-independent)

Symptom: `.~lock.<name>#` present but the user says nothing is open.
Diagnose: cat the lock; check hostname/user/time.
- user `claude` or an old agent-session hostname -> 100% stale. Ignore.
- user's own account + recent time -> may be genuinely open; ask the user.
- user's account + >1 day old -> likely crash leftover; confirm once.

Locks matter only to LibreOffice. Library writes (openpyxl etc.) succeed
regardless. Deleting the lock fails in the sandbox; just proceed.

### 4.4 NFC/NFD Unicode, Korean/CJK paths (backend-independent)

Symptom: file exists but shell says `No such file or directory`.
Cause: disk stores NFD; shell literals/scripts use NFC; byte match fails.
Fix: don't string-build paths. DC and harness-native file tools are immune. In
scripts, resolve per path component via `os.listdir` +
`unicodedata.normalize('NFC', name)`, or use glob wildcards.

### 4.5 No delete / no atomic-replace on the mount (Layer A, proxy_mount: yes)

Create/write succeed, but delete fails (`Operation not permitted`). The cause is
the harness's sandbox proxy mount, so on a `proxy_mount: yes` harness this
triggers on ANY connected folder, including a plain local one; the backend
cannot switch it off. "No cloud, no problem" is the single most common wrong
inference here.

Impact is a whole tool class, not just leftover temp files: anything relying on
delete, lockfile removal, or atomic rename breaks. git is the canonical
casualty - it cannot clear `.git/*.lock`, so commits are blocked, and a naive
"just force it" workaround corrupts repo state. The failure is silent (writes
pass, only deletes fail, so it looks fine and breaks later) and non-self-
recoverable: the agent cannot clean up inside the mount.

Rules:
- Never create temp files on the mount, and never run delete / atomic-rename /
  lockfile-dependent tools (git, build systems, anything doing atomic saves)
  with their working dir on the mount.
- Run such tools in the sandbox-local outputs dir instead, then copy only the
  final artifacts onto the mount.
- Removing anything already on the mount = the user, via the OS file manager.
  Host-side rename (`host_file_tool`; DC `move_file` on Cowork) does work; only
  the sandbox path is denied.

On `proxy_mount: no` (the agent works on the host filesystem) delete and rename
work and this section is inert. Keeping git repositories out of a synced
workspace is still wise, because sync clients and `.git` internals interfere,
but that is a backend matter, not this rule.

### 4.6 Native document stubs (native_doc_stubs)

Some backends store certain documents as a local URL stub with no body. The
profile lists the extensions. Such a file is unreadable even host-side; read it
through that backend's `connector`, or keep an `.md` copy in the workspace for
documents the agent must read often. On a profile with `native_doc_stubs: none`
this section is inert.

### 4.7 Text file writes (backend-independent)

Some environments block built-in Write/Edit on workspace paths ("protected
location"). Then the host-side file tool (§5; on Cowork DC `write_file` in
25-30 line chunks + `edit_block`) is the
standard path. Re-read after editing to verify.

### 4.8 Symptom -> cause -> fix (core)

| Symptom | Cause | Fix |
|---|---|---|
| delete not permitted | sandbox proxy mount denies unlink (Layer A, proxy_mount: yes, any folder) | no temp files on mount; run delete/atomic tools in local outputs |
| git commit blocked / can't remove *.lock | Layer A denies unlink of lockfiles | run the repo in local outputs, copy artifacts to mount; never force-remove |
| .~lock but nothing open | stale from old session | inspect lock; ignore if stale |
| No such file (CJK path) | NFC/NFD mismatch | host file tool; normalize |
| Write/Edit blocked | protected path policy | host file tool (DC write_file / edit_block on Cowork) |
| .hwp/.hwpx comes back empty, garbled, or with table text missing | binary (hwp) or zip+XML (hwpx) format; ad-hoc extraction drops cells, captions, text boxes | `_context-protocol/tools/hwp2md.py`, §4.10 |

Backend-specific symptoms (empty sandbox grep, BadZipFile, shutil.copy failure,
file opening as a URL) live in the profile's own table. If one of those appears
on a backend whose profile says it cannot, the backend was misidentified:
re-check the connected path.

### 4.9 Portable paths: resolve WS at runtime, never hardcode it

A workspace absolute path is only valid on the machine that produced it. Never
bake one into a synced file or into the project instructions the user pastes.
Keep every path in prose, synced files, and pasted instructions relative to the
workspace root; only the live session holds a composed absolute path.

How WS is resolved depends on `mount_root`.

- `mount_root: no` (plain local directory): WS is the connected absolute path,
  as given. No decomposition.
- `mount_root: yes` (cloud mount): WS = MOUNT_ROOT + REL. MOUNT_ROOT is the
  per-host, per-OS, per-account mount anchor; REL is the remainder and is the
  portable half, identical on every PC precisely because the per-host part was
  removed. The profile defines how to recognize that backend's anchor by shape,
  never by a specific account, drive, or folder name.

`CONTEXT.md` frontmatter MAY record `ws_rel_path` (the derived REL, or a
home-relative path on a local backend) for human reference and cross-project
discovery. Resolution never depends on it: if a recorded value disagrees with
the freshly derived one, trust the live derivation and refresh the record.
Never block on a mismatch, and never treat the stored value as authoritative.
`ws_backend` follows the same rule only while its `ws_backend_source` is
`inferred`; a user-declared backend is never overwritten (§0-A).

### 4.10 HWP / HWPX documents (backend-independent)

Korean government forms, business plans and applications arrive as `.hwp`
(OLE binary) or `.hwpx` (zip of XML). Neither the built-in Read tool nor a plain
text read handles them, and hand-rolled extraction fails quietly: paragraphs
come out but table cells, captions, text boxes and nested tables go missing.
A user has already been told "four sections of the essay are gone" when the
file was intact. Never answer from a partial extraction.

Fix: run `_context-protocol/tools/hwp2md.py` on the file or on a folder. It
needs only `python3`; run it in the sandbox shell, or host-side where Python is
3.10 or newer. It writes two files beside each original:

- `<name>.hwp.md`: all body text in reading order. Plain tables become markdown
  tables; tables with merged cells become HTML tables that keep `rowspan` and
  `colspan`, because flattening a merge hides which rows belong to which group.
  Captions, headers and footers, text boxes and nested tables are included.
  Standard library only; this part always runs.
- `<name>.hwp.pages.pdf`: every page drawn as an image by rhwp (pip
  `rhwp-python`, MIT). The script installs it with pip on first use. Open it
  when layout carries meaning: form fields, which box a sentence sits in,
  diagrams, charts, images. If Python is older than 3.10, pip is blocked, or
  drawing fails, the script prints `쪽그림생략` with the reason and still
  writes the `.md`.

Read the `.md` first; open the `.pages.pdf` for layout questions or to check a
table. Both are derived copies: never edit them, never treat them as the
original, and re-run the script when the original is newer. The `.md`
carries `type: document` and `derived_from: <original name>`, which keeps it
out of the decomposition signal and the integrity lint's size check. They sit next to
the original, so they are classified by the same location. `--out-dir <dir>`
writes elsewhere and `--stdout` prints the text only.

On a `lazy_hydration: yes` backend the sandbox may not see a cloud-only
original (§4.1). Hydrate it host-side first, or run the script host-side.

When the script refuses a file, ask the user to save it as PDF from Hancom
Office (파일 > PDF로 저장하기) and read the PDF instead:
- distribution (배포용) or password-protected documents: the body is encrypted;
- documents whose body is an image: fewer than 20 characters of text.

If `_context-protocol/tools/hwp2md.py` is absent (the workspace was installed
from `CONTEXT_SETUP.md` alone, without the package), ask for the PDF the same
way. Do not improvise a parser.

rhwp's own markdown export is not used for text. Measured on 2026-09-28
against seven real business plans and forms, it dropped nested tables and text
boxes (89 to 100 percent of characters kept), while its page drawing matched
Hancom's layout. So text comes from the stdlib converter and layout from rhwp.
Its 0.8.x Linux wheels bundle an old freetype that fails to import
(`undefined symbol: FT_Palette_*`); the script preloads the system libfreetype
to get around it. Do not debug that by hand.

## 5. Tool rule: host-side file work goes through the harness's file tool

All local (host) work goes through the tool the harness profile names as
`host_file_tool` (§0-B). On Claude Cowork that is Desktop Commander (DC). On a
harness that works on the host filesystem (Claude Code, Codex, Cursor,
Antigravity, Grok Build) it is that harness's own file and shell tools.

Three reasons; only the first depends on the backend:
1. (lazy_hydration: yes) a sandbox shell cannot see unhydrated files. The
   host-side tool hydrates them only when its own process may materialize them
   (§4.1).
2. Path handling: the tool must be immune to the NFC/NFD trap (§4.4) and to
   string-built path breakage. DC and harness-native file tools are; hand-built
   shell paths are not.
3. Write discipline: chunked writes and exact-match edits are what the write
   protocol (§6) assumes.

So the host-side tool stays the default even on a backend where reason 1 is off.

DC operations (claude-cowork profile; other profiles map the same roles to their
own tools):
- search: `start_search` (searchType=files/content)
- read: `read_file` / `read_multiple_files`
- write: `write_file` (25-30 line chunks); edit: `edit_block`
- dirs: `list_directory`, `move_file`, `create_directory`
- shell: `start_process` / `interact_with_process`

Not the host file tool:
- native document stubs -> the backend's connector (§4.6)
- items outside the workspace folder that only the backend service holds -> its connector
- image/PDF visual checks, doc-generation skills (docx/xlsx/pptx/pdf) -> built-ins/skills

Caution: the host-side tool runs directly on the host (no isolation). Destructive ops
(delete/overwrite/chmod) only with user approval. If the sandbox is truly
needed (package installs etc.), use it as auxiliary.

## 6. Write protocol

Before writing: check the MEMORY.md index for an existing entry and edit it.
No duplicates. Kind first: durable curated knowledge (domain docs, policies, ops
guides, a decision written up as a document) is NOT a memory - it lives as
content files in the narrowest concept folder that fits, one topic per file (§10,
§12.2), co-located with related files. memory/ is
the LLM memory layer; only memory-layer facts (user identity, preferences,
feedback, in-flight project/task status) go there, and knowledge is never routed
into it. Location: sensitive -> private; verified shareable -> public;
session-scratch only -> L0.

Agent-memory override: a harness may keep a memory of its own (`agent_memory`,
§0-B): Claude's host auto-memory directory, Codex or Grok saved memories, a chat
product's account memory. Its built-in instructions point there. In protocol
workspaces that default is overridden. Such memory is bound to one host or
account and one harness: on a multi-PC backend a body saved there silently does
not exist on the user's other machines, another harness opening the same
workspace never sees it, and on any backend it forks the SoT away from the
workspace and blocks the proper save.
Memory-layer bodies always go to `<ws>/memory/`; agent memory gets at most a
one-line pointer (`- <topic>: see <ws>/memory/<topic>.md`). Knowledge is not a
memory body - it is a content file in its concept folder (see the Kind rule
above), so it never lands in memory/. A body file in
agent memory is a bug: migrate it to the workspace and replace it with a
pointer. Where the agent memory has an index file (Claude's auto-memory
MEMORY.md), keep it a router-only file with a
warning header (no topic entries), so future sessions cannot re-grow it.
Test: "where is X stored?" must answer with a workspace path.

Sensitive info routing: the workspace is the user's own file storage, not
agent memory. Recording user-directed sensitive info (personal, HR,
financial, business-confidential) in the private workspace is normal file
creation; explicit user direction = consent. Do not refuse on "sensitive
memory" grounds - those restrictions govern agent memory. Never place
such content in public or in agent memory.

Memory file standard (frontmatter required):

```markdown
---
name: <short-id>
description: <one line; how a future agent judges relevance>
type: user | feedback | project | reference
updated: YYYY-MM-DD
---

<body>
**Why:** <reason>
**How to apply:** <trigger conditions>
```

Index rules (8.1): `memory/MEMORY.md` is the memory-layer router. One line per
memory body in `memory/`, `- [Title](file.md) - hook` (<=150 chars). Nothing
else is listed there or in any other hand-kept index: concepts, projects, domain
folders, ops guides and content files are classified by location and found by
search (§3-A); live views (`_views/`) compute any list a person wants to see.
A hook says what the body is about and carries no value that goes stale
(version numbers, prices, current status): a stale hook sends the next session
to a superseded answer, which was measured on a team workspace on 2026-11-06.

Concurrency:
- Always read before writing. No blind full overwrite.
- Always bump `updated`. If read-date != write-date, re-read and merge.
- (sync_lag: yes) another host's latest may not be local yet. On conflict,
  don't overwrite; report to the user.

Project descriptor upkeep: when a session changes the workspace's concept
structure (adds/removes a concept in `_context-protocol/_concepts/` or a folder
concept) or changes persona.scope or the topics covered, update `_project.md` in
the same task - its `suitability.subjects`, `keywords`, `persona`, and
`updated`. Treat this as post-processing in the same task. Follow this section's write protocol. Full descriptor spec: §11.

## 7. Freshness / TTL

TTL applies only to snapshots of volatile data. Curated knowledge, policies,
and guides never expire; edit only on explicit change.

| Kind | TTL | On expiry |
|---|---|---|
| live-source cache (L2) | 1 day | re-query L3, new dated cache file |
| org/cost snapshots | quarterly | request latest source |
| domain knowledge / policies / guides | none | edit only on explicit change |
| project in-flight status | 7 days | confirm completion |
| L0 thin pointers | none | update when L1 location moves |

## 8. Applying to a new project

1. Pick the backend (§0-A) and create the workspace folder(s): a cloud synced
   folder for multi-PC, or a plain local directory for one machine. Optionally
   public + private. Connect it as the session's working folder.
2. Standard structure:

```
<workspace>/
  CONTEXT.md                # rule canon and session entry; frontmatter carries ws_backend + ws_rel_path
  AGENTS.md                 # portal into CONTEXT.md (Codex, Cursor, Antigravity, Grok Build)
  CLAUDE.md                 # portal into CONTEXT.md (Claude Code, Cowork)
  _project.md               # project descriptor: import-discovery marker (sec 11)
  memory/
    MEMORY.md               # index (starts empty)
    <topic>.md              # individual memories
  action-log/
    action-log.md           # folder concept for the time-axis stream (sec 12.3)
    YYYY-MM-DD.md           # one file per day, created lazily
  cache/
    <topic>/YYYY-MM-DD.md
  <domain>/                 # domain docs and ops guides (folder = concept)
  _context-protocol/        # everything the protocol needs to run, kept out of the root (sec 10)
    CONTEXT_GUIDE.md        # copy of this guide
    backends/
      storage-backend.md    # backend concept: capability contract + detection
      <backend_id>.md       # one profile per supported backend
    harnesses/
      agent-harness.md      # harness concept: capability contract + detection
      <harness_id>.md       # one profile per supported harness
    _ontology.md _concepts/ _schema/ _views/ _concepts.base   # ontology helpers
```

3. Write the two portals, AGENTS.md and CLAUDE.md (§0-B). Where the harness
   also has a pasted instruction layer (`bootstrap_block: yes`) or an
   agent-memory index, plant a router there too: "on session start, read the
   workspace CONTEXT.md first".
4. In the first session, verify the §3 lookup order and §3-A hard rules fire.
5. Create the ontology layer (structure-first, section 10). No schedule to
   register - views render live in Obsidian.
6. Write `_project.md` at the workspace root (§11).
7. Record `ws_backend` (with `ws_backend_source`) and `ws_rel_path` in
   `CONTEXT.md` frontmatter (§0-A, §4.9). `ws_rel_path` and an inferred backend are
   reference records that resolution re-derives each session; a user-declared
   backend is binding.

## 9. Maintenance (monthly)

- MEMORY.md size: consolidate if >200 lines.
- Report memories with `updated` >90 days old.
- Sample-validate MEMORY.md lines (dangling pointers, hooks that went stale).
- Report cache/ files older than 7 days.
- Open _context-protocol/_views/integrity-lint.md; resolve any missing fields,
  dangling links, or broader cycles it flags.
- `_project.md` freshness: is `updated` stale, do all `suitability.subjects`
  links still resolve, and does `persona.scope` still match the actual folder
  structure? Refresh if drifted (§11.4).
- Backend record: does `ws_backend` still match the connected path shape? If
  `ws_backend_source: user`, report a mismatch and ask. Otherwise a
  workspace that was moved between backends needs the record refreshed and the
  profile re-read.
- Portals: do AGENTS.md and CLAUDE.md still hold only the pointer and the
  nested-workspace rule? Move any rule that grew in a portal into CONTEXT.md.

## 10. Ontology layer (structure-first, co-located)

The filesystem itself is the ontology. Folder location carries concept
membership and hierarchy, the filename carries document identity, and md
originals carry their relations in their own frontmatter. There is no separate
index tree and no `source` pointer: an md file classifies itself. Still
file-only: no database, no server, no MCP, no batch. It travels with the
workspace folder, so a new host just opens the vault.

Three ways a thing is classified:
1. By location (primary): a file in folder `X/` belongs to concept `X`; nesting
   `X/Y/` means concept Y's broader is X. Moving a file is classifying it.
2. By frontmatter: an md sets `subject: ["[[concept]]"]`. Required for fixed-path
   scaffold files that cannot sit under their concept folder, and for multi-membership.
3. By inference: non-md files (xlsx, pdf, native docs) carry no metadata; meaning is read
   from filename + folder + any md that references them. Any non-md knowledge file (a policy PDF, a data xlsx, a slide
   deck) drops into its concept folder as-is (classified by that location); add a
   short companion md only if the agent must reference or read it often.

One original, one location. Never use a symlink, a hard link, or a copy to make
the same file visible from two folders; express multi-membership in frontmatter
instead. Three reasons:
1. (symlink_registered: no) the backend does not register a link as an item, so
   the link never reaches another host and the file simply is not there. On
   Google Drive this is measured, not assumed - see `_context-protocol/backends/gdrive.md`. Where
   the profile says `symlink_registered: yes` this reason is absent and the
   remaining two still decide it.
2. Location is a classification claim. A file in two places makes two claims and
   lint has no basis to pick the canonical one.
3. Copies diverge. The moment one side is edited there are two originals and no
   way to tell which is current from the files alone.

A fourth, portability: a workspace that allowed links under a permissive backend
breaks quietly when it moves to a stricter one. Keeping one structural rule for
all backends is cheaper than per-backend structure.

Instead: keep the original in its concept folder and point at it with a wikilink
from the other side's frontmatter (`links.locatedAt: "[[localhost-web3]]"`), plus
the reverse link on the original (`links.usedBy`). Wikilinks resolve by filename,
not path, so moving the file later does not break them - the opposite of a symlink,
which is bound to its path.

Concepts come in two shapes:
- Folder concept: a concept that owns a folder holds its concept note inside that
  folder, named as the concept id (e.g. `memory/memory-system.md`), so
  `[[memory-system]]` resolves. `broader` names the parent concept.
- Abstract concept: no owning folder (e.g. context-infrastructure). Lives in
  `_context-protocol/_concepts/<id>.md`.

Everything the protocol needs only to run is grouped under `_context-protocol/`:
this guide (`CONTEXT_GUIDE.md`), the backend folder concept and its profiles
(`backends/`), the harness folder concept and its profiles (`harnesses/`), installer copies when a workspace keeps them (`installers/`), and
the ontology helpers: `_concepts/` (abstract concepts), `_schema/concept-scheme.md` (vocabulary and
rules), `_views/` (index-moc.md, integrity-lint.md; Dataview, live),
`_concepts.base` (Obsidian table), `_ontology.md` (this layer's readme).
`CONTEXT.md`, its portals (`AGENTS.md`, `CLAUDE.md`) and `_project.md` stay at
the workspace root: the rule canon, the files harnesses load on their own, and
the import-discovery marker (§11) are found by fixed root paths,
deliberately outside the cluster. `memory/` and `action-log/` also stay at the
root, since people read them too.
Do not hide the cluster behind a leading dot. Obsidian ignores dot folders
entirely (views and wikilinks into them break), and most agent search tools skip
hidden paths by default, which turns the §3-A search into a false "not found".
The concept scheme
also allows a `project-descriptor` note type, self-classified like the
fixed-path scaffold files (exempt from the `subject` requirement); its
`suitability.subjects` links are lint-checked against real concept notes.

Relations live in frontmatter, `broader` one way only; never write `narrower`
(index-moc computes it in reverse). Validation is not a batch: open
`_context-protocol/_views/integrity-lint.md` for live violations. Headless checks are a plain file
scan (excluding `_deprecated_*/`): every `broader`/`subject` link resolves, and
every document md is classified either by a concept folder or by `subject`.

Two document relations tie curated knowledge to the files it stands on (7.3).
`grounded_on` lists the originals a curated note was written from, so lint can
flag a note whose original changed after the note was last updated or checked.
The flag is a review signal, not an error: modified times also move on sync,
so the judgment is made by opening the original. `supersedes` lists the earlier
versions a document replaces. A version is not edited once superseded, which
keeps "which one is current" in the files instead of in timestamps. Both accept
wikilinks to non-md files with the extension (`[[plan-v2.pdf]]`). Definitions
live in the concept scheme; the workflow is in `_context-protocol/_ontology.md`
("정리 노트의 근거", "판이 바뀌는 문서").

To add: put content md in its concept folder (classified by location) or set
`type: document` + `subject` in its frontmatter; add a concept as a folder note
or in `_context-protocol/_concepts/`. See
`_context-protocol/_ontology.md` for the full workflow.

## 11. Project descriptor (`_project.md`) and cross-project import

A workspace can reference-load another protocol workspace's curated knowledge
(L1) read-only, to widen exploration on the current session's topic. That
discovery needs each workspace to describe itself with one standard marker
file. The descriptor is a protocol-standard artifact, not a byproduct of any
one skill: without it a workspace cannot be discovered at all.

### 11.1 The marker file

- Location / filename: exactly `_project.md` at the workspace root - the one
  underscore marker that stays at root, deliberately outside the
  `_context-protocol/` helper cluster so discovery can find it by a fixed
  path.
- Meaning: the file's existence marks the folder as an importable protocol
  workspace.
- Discovery contract (important): discovery is by filename convention, not by
  path. The protocol guarantees this filename is the same global constant in
  every user environment. Discovery must not depend on a particular folder name
  or index filename.

### 11.2 Schema

```markdown
---
type: project-descriptor
project: <workspace id, e.g. claude-coworker>
persona:
  role: <domain/role of this context, e.g. "Korean statute research context">
  scope: <one line: what this context covers>
  voice: <optional: output tone/style>
suitability:
  subjects: ["[[concept-id]]", ...]   # ontology concepts this workspace owns
  keywords: [keyword1, keyword2, ...]  # topic-match signals
  import_when: <session topics for which importing this helps>
  import_not_when: <optional: when importing is wrong>
# override keys (all optional; omit = empty list / false; back-compatible; §11.7):
import_pin: ["<workspace-id>", ...]     # hub only: always-consider (bypass match floor)
import_mute: ["<workspace-id>", ...]    # hub only: exclude from auto-discovery
import_optout: false                     # target only: self-exclude even if public
visibility: public | private
updated: YYYY-MM-DD
---

<free text: what importing this context gives you, and entry points
(which memory/docs to read first)>
```

`suitability.subjects` lists the ontology concepts this workspace owns (wiki
links to real concept notes). `keywords` / `import_when` are the topic-match
signals. `visibility` inherits §2 rule 4.

### 11.3 Concept-scheme integration

`project-descriptor` is an allowed note type (`_context-protocol/_schema/concept-scheme.md`).
Being a fixed-path root file it self-classifies and is exempt from the `subject`
requirement, and is excluded from the broader/subject membership integrity
checks. One added lint rule: every link in `suitability.subjects` must resolve
to a real concept note. This does not break the existing integrity-lint.

### 11.4 Keeping it fresh (ties to §6)

A stale `_project.md` makes matching wrong. Event triggers: adding/removing a
concept (`_context-protocol/_concepts/` or a folder concept), changing `persona.scope`, or
changing the topics covered - update `suitability.subjects` / `keywords` /
`persona` in the same task. Write per §6 (read first, bump `updated`, re-read
and merge on date skew). Self-upkeep: whenever a session changes the
workspace's concept structure, updating `_project.md` is post-processing on par
with refreshing the ontology index.

### 11.5 Migrating an existing workspace (adds `_project.md`)

Existing workspaces predate the descriptor. Migration is an explicit write
action, separate from import (import never writes to the target). Auto-draft
source: read the target's CONTEXT.md (CLAUDE.md before 8.0; entry point / role) + `_context-protocol/_concepts/` and
folder concepts (subjects) + `memory/MEMORY.md` (topics) to fill persona +
suitability, generate a draft, announce it, and let the user refine. Idempotent:
if `_project.md` already exists, do not overwrite - only run the freshness
check (§11.4 / §9).

### 11.6 Safety / exposure contract

- Read-only import: reference-loading another workspace never writes to the
  target. Writes happen only in §11.4 upkeep or §11.5 migration.
- Visibility (inherits §2 rule 4): only public descriptors are auto-exposed
  across sessions. Private / secret workspaces either carry no descriptor or are
  excluded from the discovery scan (opt-in); never auto-expose a secret-natured
  workspace.
- Host-tool premise (inherits §5): discovery and load run through host tools
  (`host_file_tool`; Desktop Commander on Cowork). On a `lazy_hydration: yes`
  backend this is also what
  hydrates cloud-only candidates; do not assume sandbox visibility.

### 11.7 User override keys (optional)

Three optional descriptor keys let the user override auto-discovery and persist
that across sessions. All are optional; a descriptor without them stays valid
(omit means empty list / false), and their presence does not break
integrity-lint (project-descriptor stays self-classified).

- `import_pin: ["<workspace-id>", ...]` (hub `_project.md`): always-consider
  candidates - loaded whenever topic-relevant, regardless of the auto-match
  floor.
- `import_mute: ["<workspace-id>", ...]` (hub `_project.md`): excluded from auto
  discovery.
- `import_optout: true|false` (target `_project.md`): a public workspace excludes
  itself from being imported (default false).

Values are not validated: `import_pin` / `import_mute` hold workspace-id strings
(the target may not exist on another host, so no existence check); `import_optout`
is boolean. The protocol only defines these keys. The priority order (session
instruction > persistent setting (pin/mute) > optout > auto-match) is owned by
the import skill spec, not this protocol.

## 12. Active accumulation + action-log

Lookup is SoT-first and stays that way (§3). This section changes only writing:
from passive (waiting for an explicit "기억해줘") to active. When a conversation
surfaces a durable fact, decision, or dated event, record it into the workspace
right after answering, without asking the user first, then report where it went.

### 12.1 Accumulation triggers

Fire the accumulation flow (§12.2 routing) when any of these appears:

- New concept or domain shows up that the ontology does not yet hold.
- A fact in an existing document/concept changes (a value, a decision reversed).
- A dated event or state change (something happened on a date; a status moved).
- User identity, preference, feedback, or in-flight project/task status.
- Strong signal: you answered "not found / unknown", and the user then filled
  the blank. That correction is durable - capture it.

Skip volatile-only facts (live-source snapshots governed by §7 TTL) and content
that matters to this conversation alone. When unsure whether something is
durable, prefer recording a short note over losing it.

Record a correction at the scope it was given (this file, this deliverable,
this client). Promote it to a general rule, a feedback memory that binds future
work, only when the same direction of correction shows up again in a different
context, or when the user scopes it that way themselves ("앞으로", "항상",
"모든"). A single correction inflated into a standing rule is a silent
overreach: later sessions obey it without knowing it rests on one instance.
When promoting, note the instances the rule rests on.

### 12.2 Routing by kind (knowledge != memory != log)

Route by what the thing IS, never dump everything into one sink:

- Durable curated knowledge (a concept, a policy, an ops fact, a decision
  written up) -> the narrowest concept folder that fits, one topic per file
  (§10). Never into memory/. Before appending to an existing file, re-read its
  one-line definition (a concept's `definition`, a document's H1 and first
  paragraph); an addition that falls outside it is another file or a new
  sub-concept. Count the aspects before writing: content spanning three or
  more aspects gets its sub-concept folders first, then one topic file per
  aspect, and a project-grade concept (project, product, business idea) is
  born with its axes, a decision log and a glossary (`_context-protocol/_ontology.md`,
  "쓰기 전에 분해한다"). Content that came out of a conversation keeps what the
  user stated apart from what the agent proposed and the user has not adopted
  (concept scheme, "본문 절 규약"); a transcript kept as-is is a raw record
  (`canon_note`) and the decomposed notes win over it.
- Memory-layer fact (user identity, preference, feedback, in-flight status)
  -> `memory/<topic>.md` + a line in `memory/MEMORY.md` (§6).
- Dated event / state change -> append a line to the action-log (§12.3). If the
  event also changed a concept/document, update that original per §6 AND log a
  line linking to it (dual write).
- Sensitive info -> private workspace only. Never public, never agent memory (§6).

All three sinks follow the §6 write protocol (read index + target first, edit on
duplicate, bump `updated`, re-read and merge on date skew, chunked writes via
the host file tool). If a new concept/folder is created, it must pass
integrity-lint (broader x1, links resolve, DAG, no orphan md); if concept
structure changed, update `_project.md` in the same task
(§6 project-descriptor upkeep).

At the end of the answer, report what was written and where, by path.

### 12.3 action-log (time-axis stream)

The action-log is a knowledge stream, not memory, so it lives at its own concept
folder `action-log/`, not under `memory/`. Full spec and entry format live in the
concept note `action-log/action-log.md`; the essentials:

- The time axis is expressed only by filename: one file per day, named
  `action-log/YYYY-MM-DD.md`, with entries appended as top-level bullets under a
  single H1 title. Do not repeat the date as an in-file heading; the filename is
  the date, and `YYYY-MM-DD` sorts lexically in chronological order. It is never
  a folder hierarchy - date folders would be misread as concepts and break lint
  (§10), and even a single year folder would force a permanent lint exception.
  Day granularity keeps the append target small: reading the last few days means
  reading a few short files instead of scanning a whole year. Year files
  (`action-log/2026.md`) are the pre-4.9 shape; where one survives, its content
  has been split into day files and it is kept only because the mount denies
  deletion - never append to it.
- Each entry carries at minimum: what happened, the original path(s) updated
  alongside it, the source, and its check level (8.2): `직접 확인` when the
  writing agent saw the result itself in this session (opened the changed file,
  got the command output, heard the user state the decision), `보고됨(<who>)`
  when a person, another session or a worker only said it happened. When unsure,
  write 보고됨. Open the original before building on a reported entry; a later
  check appends a new 직접 확인 entry naming the old entry's date and never edits
  the old one. Entries older than 8.2 carry no check line and read as reported.
- Relative time is converted to absolute before writing (YYYY-MM-DD; never leave
  "yesterday").
- Append via `write_file` (mode append); no temp files, no atomic-rename on the
  mount (§4.5).
