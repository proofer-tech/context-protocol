---
type: view
title: Integrity lint
---

# 무결성 점검 (실시간, v4)

이 노트를 열면 현재 상태로 위반을 보여줍니다. 규칙 표들이 모두 비어 있으면 통과.
마지막 "검토 신호" 절은 통과 여부에 넣지 않습니다.
`_deprecated_v3/`, `_deprecated_v5/` 는 점검에서 제외합니다.

## 규칙 1) broader 누락 concept (top concept 제외)

```dataview
TABLE broader
FROM -"_deprecated_v3" AND -"_deprecated_v5"
WHERE type = "concept" AND !broader AND file.name != "context-infrastructure"
```

## 규칙 3) 소속 미결정 document (위치도 subject도 없음)

```dataviewjs
const conceptFolders = new Set(dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p=>p.type==="concept" && !p.file.folder.endsWith("_concepts")).map(p=>p.file.folder).array());
const skip = new Set(["concept","view","schema","readme","proposal","project-descriptor"]);
const orphans = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.file.ext==="md" && !skip.has(p.type) && !p.subject && !conceptFolders.has(p.file.folder));
if (orphans.length) dv.table(["소속 미결정 md","폴더"], orphans.map(p=>[p.file.link, p.file.folder]));
else dv.paragraph("소속 미결정 문서 없음. 통과.");
```

## 규칙 2) 댕글링 링크 점검

```dataviewjs
const pages = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "concept" || p.type === "document")
const rows = []
for (const p of pages) {
  const links = []
  if (p.broader) links.push(...(Array.isArray(p.broader)? p.broader : [p.broader]))
  if (p.subject) links.push(...(Array.isArray(p.subject)? p.subject : [p.subject]))
  if (p.canon_note) links.push(...(Array.isArray(p.canon_note)? p.canon_note : [p.canon_note]))
  for (const l of links) {
    const target = l && l.path ? dv.page(l.path) : null
    if (!target) rows.push([p.file.link, l ? (l.path || String(l)) : "(빈 링크)"])
  }
  const fileLinks = []
  if (p.grounded_on) fileLinks.push(...(Array.isArray(p.grounded_on)? p.grounded_on : [p.grounded_on]))
  if (p.supersedes) fileLinks.push(...(Array.isArray(p.supersedes)? p.supersedes : [p.supersedes]))
  for (const l of fileLinks) {
    const target = l && l.path ? app.metadataCache.getFirstLinkpathDest(l.path, p.file.path) : null
    if (!target) rows.push([p.file.link, l ? (l.path || String(l)) : "(빈 링크)"])
  }
}
if (rows.length) dv.table(["노트", "댕글링 대상"], rows)
else dv.paragraph("댕글링 없음. 통과.")
```

## 규칙 4) broader 순환 점검

```dataviewjs
const pages = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "concept")
const parent = {}
for (const p of pages) {
  const b = p.broader && p.broader.path ? p.broader.path : (Array.isArray(p.broader) && p.broader[0] ? p.broader[0].path : null)
  parent[p.file.path] = b
}
const bad = []
for (const start of Object.keys(parent)) {
  let cur = parent[start], seen = new Set([start]), steps = 0
  while (cur && steps < 50) {
    if (seen.has(cur)) { bad.push(start); break }
    seen.add(cur); cur = parent[cur]; steps++
  }
}
if (bad.length) dv.list(bad)
else dv.paragraph("순환 없음. DAG 통과.")
```

## 규칙 6) project-descriptor suitability.subjects 링크 점검

```dataviewjs
const pages = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "project-descriptor")
const rows = []
for (const p of pages) {
  const subs = p.suitability ? p.suitability.subjects : null
  const list = subs ? (Array.isArray(subs) ? subs : [subs]) : []
  for (const l of list) {
    let target = null, label = String(l)
    if (l && l.path) { target = dv.page(l.path); label = l.path }
    else if (typeof l === "string") { const id = l.replace(/\[\[|\]\]/g, ""); target = dv.page(id); label = id }
    if (!target || target.type !== "concept") rows.push([p.file.link, label])
  }
}
if (rows.length) dv.table(["_project.md", "미해결 subjects 링크"], rows)
else dv.paragraph("project-descriptor subjects 링크 정상. 통과.")
```

## 검토 신호) 분해 검토 (오류 아님)

통과 여부에 넣지 않는다. 하위 개념 폴더가 없는 개념 폴더 안에서 200줄을 넘거나 출처
절(확정, 제안, 열린 질문)을 뺀 H2 가 5개를 넘는 md 를 띄운다. 판정은 정의 시험으로
한다(`_context-protocol/_ontology.md` "쓰기 전에 분해한다").

```dataviewjs
const inScope = p => !p.file.path.includes("_deprecated_") && !p.file.path.startsWith("_context-protocol/") && !p.file.path.startsWith("memory/") && !p.file.folder.split("/").includes("action-log")
const pages = dv.pages().where(inScope)
const conceptFolders = pages.where(p => p.type === "concept" && !p.file.folder.endsWith("_concepts")).map(p => p.file.folder).array()
const hasSub = f => conceptFolders.some(c => c !== f && c.startsWith(f + "/"))
const skip = new Set(["view","schema","readme","proposal","project-descriptor"])
const prov = /^##\s+(확정|제안|열린 질문|Confirmed|Proposed|Open questions)/
const rows = []
for (const p of pages.where(p => p.file.ext === "md" && !skip.has(p.type) && !p.canon_note && !p.derived_from && conceptFolders.includes(p.file.folder) && !hasSub(p.file.folder))) {
  const text = await dv.io.load(p.file.path)
  if (!text) continue
  const lines = text.split("\n")
  const h2 = lines.filter(l => /^##\s/.test(l) && !prov.test(l)).length
  if (lines.length > 200 || h2 > 5) rows.push([p.file.link, p.file.folder, lines.length, h2])
}
if (rows.length) dv.table(["분해 검토 문서", "폴더", "줄 수", "H2 (출처 절 제외)"], rows)
else dv.paragraph("분해 검토 대상 없음.")
```

## 검토 신호) 신뢰 역전 (오류 아님)

통과 여부에 넣지 않는다. `trust_tier` 가 있는 노트의 등급이 `grounded_on` 원본 중 등급이 있는
것의 가장 낮은 등급보다 높으면 띄운다(concept scheme "검토 신호"). 키가 없는 문서는 보지 않는다.

```dataviewjs
const rank = { verified: 3, sourced: 2, unverified: 1 }
const pages = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "document" && p.trust_tier && p.grounded_on)
const rows = []
for (const p of pages) {
  const mine = rank[String(p.trust_tier)]
  if (!mine) { rows.push([p.file.link, String(p.trust_tier), "(허용값 verified, sourced, unverified 가 아니다)"]); continue }
  const list = Array.isArray(p.grounded_on) ? p.grounded_on : [p.grounded_on]
  let low = null, lowPath = null
  for (const l of list) {
    const src = l && l.path ? dv.page(l.path) : null
    const r = src && src.trust_tier ? rank[String(src.trust_tier)] : null
    if (r && (low === null || r < low)) { low = r; lowPath = src.file.path }
  }
  if (low !== null && mine > low) rows.push([p.file.link, String(p.trust_tier), lowPath])
}
if (rows.length) dv.table(["노트", "노트 등급", "더 낮은 근거 원본"], rows)
else dv.paragraph("신뢰 역전 없음.")
```

## 검토 신호) 근거 drift (오류 아님)

통과 여부에 넣지 않는다. `grounded_on` 원본의 수정 시각이 노트의 `updated` 와
`grounded_checked` 중 늦은 날의 끝보다 뒤인 노트를 띄운다. 동기화로도 수정 시각이 바뀌므로
오탐이 난다. 원본을 열어 대조하고, 노트를 고쳤으면 `updated`, 고칠 것이 없었으면
`grounded_checked` 를 그날로 바꾼다(`_context-protocol/_ontology.md` "정리 노트의 근거").

```dataviewjs
const pages = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "document" && p.grounded_on)
const ts = v => v ? (v.ts ?? Date.parse(String(v))) : 0
const rows = []
for (const p of pages) {
  const base = Math.max(ts(p.updated), ts(p.grounded_checked)) || p.file.mtime.ts
  const list = Array.isArray(p.grounded_on) ? p.grounded_on : [p.grounded_on]
  for (const l of list) {
    const f = l && l.path ? app.metadataCache.getFirstLinkpathDest(l.path, p.file.path) : null
    if (f && f.stat.mtime > base + 86400000) rows.push([p.file.link, f.path, new Date(f.stat.mtime).toISOString().slice(0, 10)])
  }
}
if (rows.length) dv.table(["정리 노트", "바뀐 근거 원본", "원본 수정일"], rows)
else dv.paragraph("근거 drift 없음.")
```
