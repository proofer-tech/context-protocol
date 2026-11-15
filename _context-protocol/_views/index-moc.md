---
type: view
title: Ontology index (MOC)
---

# 온톨로지 인덱스 (실시간, v4)

이 파일은 손으로 편집하지 않습니다. 아래 Dataview 쿼리가 vault 전체(_deprecated_v3
제외)를 읽어 항상 최신으로 렌더합니다.

## 개념 계층 (broader 기준)

```dataview
TABLE pref_label_ko AS "라벨", broader AS "상위(broader)"
FROM -"_deprecated_v3" AND -"_deprecated_v5"
WHERE type = "concept"
SORT broader ASC
```

## Top concept 의 하위(narrower) - 역계산

```dataview
LIST
FROM -"_deprecated_v3" AND -"_deprecated_v5"
WHERE type = "concept" AND contains(broader, link("context-infrastructure"))
```

## 개념별 문서 매핑 (subject 기준)

```dataview
TABLE rows.file.link AS "문서"
FROM -"_deprecated_v3" AND -"_deprecated_v5"
WHERE type = "document" AND subject
FLATTEN subject AS s
GROUP BY s AS "개념"
```

## 위치 기반 멤버십 (폴더=개념)

subject 를 안 적고 개념 폴더 위치만으로 속한 파일들입니다.

```dataviewjs
const concepts = dv.pages('-"_deprecated_v3" AND -"_deprecated_v5"').where(p => p.type === "concept" && !p.file.folder.endsWith("_concepts"));
let any = false;
for (const c of concepts) {
  const members = dv.pages(`"${c.file.folder}"`).where(p => p.file.path !== c.file.path && p.type !== "concept" && p.file.ext === "md");
  if (members.length) { any = true; dv.header(4, `${c.file.name} (${c.file.folder})`); dv.list(members.file.link); }
}
if (!any) dv.paragraph("위치 기반 멤버 없음.");
```
