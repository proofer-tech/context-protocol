---
type: concept
scheme: context-protocol
pref_label_ko: 제품 아이디에이션 템플릿
pref_label_en: Product ideation templates
broader: "[[product-ideation]]"
related:
definition: product-ideation 뼈대의 파일별 생성 템플릿. 프로젝트, 축, 측면 개념 노트와 주제 문서, 결정이력, 용어, 원 기록의 frontmatter 와 본문 골격을 담는다.
updated: 2026-09-25
---

# 제품 아이디에이션 템플릿 (폴더 개념)

이 노트는 `presets/product-ideation/templates/` 폴더의 개념 노트다. 다른 프리셋의
`object-template` 과 이름이 겹치지 않도록 개념 id 에 프리셋 이름을 붙였다.

## 수록 템플릿

| 파일 | 만드는 것 | 놓는 곳 |
|---|---|---|
| `project.md.tpl` | 프로젝트 개념 노트 | `<프로젝트>/<프로젝트>.md` |
| `axis.md.tpl` | 축 개념 노트 | `<프로젝트>/<축>/<slug>-<축-id>.md` |
| `aspect.md.tpl` | 측면 개념 노트 | `<축>/<측면>/<slug>-<측면-id>.md` |
| `topic.md.tpl` | 주제 문서 | `<측면>/<주제>.md` |
| `decision-log.md.tpl` | 결정이력 | `<프로젝트>/결정이력.md` |
| `glossary.md.tpl` | 용어 | `<프로젝트>/용어.md` |
| `raw-record.md.tpl` | 원 기록 | `<프로젝트>/<종류>_<YYYYMMDD>.md` |

## 사용법

`.tpl` 을 읽고 `{{...}}` 를 채워 `.md` 로 쓴다. `{{date}}` 는 오늘 날짜의 절대값,
`{{scheme_id}}` 는 대상 워크스페이스 concept-scheme 의 `scheme_id`, `{{parent_concept}}`
는 프로젝트 묶음 개념이다. `<...>` 는 안내 문장이라 채우면서 지운다. 남기면 인스턴스가 설계
문서를 흉내 낸다.

`.md.tpl` 로 두는 이유는 다른 프리셋과 같다. `.md` 면 lint 가 빈 인스턴스로 읽고, 비-md
파일은 메타 검사 대상이 아니다.

## 템플릿이 지키는 규약

- 개념 노트는 `broader` 1개와 한 줄 `definition` 을 갖고 본문은 목록만 든다.
- 주제 문서는 본문 절 규약(확정 / 제안 (미확정) / 열린 질문)을 따른다. 빈 절은 지운다.
- 코어 스킴에 등재된 키만 쓴다. `status` 같은 키가 필요하면 먼저 대상 워크스페이스
  스킴에 등재한다(스키마 우선).
- 날짜는 `updated` 와 표의 결정일 말고는 미리 채우지 않는다.
