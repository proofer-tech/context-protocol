---
type: document
title: product-ideation 점검
updated: 2026-09-25
---

# 점검

프로젝트 폴더 하나를 헤드리스로 점검한다. 코어 integrity-lint(규칙 1~6 과 분해 검토
신호)를 먼저 통과한 뒤에 돌린다. 이 점검은 수용 기준을 기계로 볼 수 있는 만큼 본다.

## 점검 목록

| # | 항목 | 등급 |
|---|---|---|
| 1 | 프로젝트 폴더에 같은 이름의 개념 노트가 있다 | 오류 |
| 2 | 루트에 결정이력과 용어가 있다(`결정이력.md` 또는 `decision-log.md`, `용어.md` 또는 `glossary.md`) | 오류 |
| 3 | 개념 노트를 가진 축 폴더가 2개 이상이다 | 오류 |
| 4 | 축마다 개념 노트를 가진 측면 폴더가 1개 이상이고, 측면마다 주제 문서가 1개 이상이다 | 오류 |
| 5 | 개념 노트의 `broader` 가 바로 위 폴더의 개념을 가리킨다 | 오류 |
| 6 | 프로젝트 개념 노트에 축 경계 문장이 있다("경계" 또는 "boundary" 가 든 문장) | 경고 |
| 7 | 200줄을 넘거나 출처 절을 뺀 H2 가 5개를 넘는 md 가 없다(원 기록 제외) | 경고 |
| 8 | 주제 문서마다 `## 확정`(또는 `## Confirmed`) 절이 있다 | 경고 |
| 9 | `canon_note` 를 가진 원 기록은 H1 아래에 정본 우선 문장이 있다 | 오류 |
| 9b | 이름에 날짜가 붙은 md(`*_YYYYMMDD.md`)가 `canon_note` 없이 있다. 원 기록이면 표식을 붙이고, 판본 산출물(IR 설계 v1.0 같은 것)이면 넘긴다 | 경고 |
| 10 | `memory/MEMORY.md` 에 프로젝트 줄이, `_project.md` 에 프로젝트와 축 위키링크가 있다 | 오류 |
| 11 | action-log 에 프로젝트 이름이 든 엔트리가 있다 | 경고 |

경고는 판단이 필요한 항목이다. 9b 는 날짜 붙은 판본 산출물에서도 켜진다. 6 은 문장을 찾을 뿐 경계가 맞는지는 못 본다. 8 은 참고
지식 문서처럼 규약 대상이 아닌 문서에서도 켜진다. 사람이 보고 넘긴다.

한 문서가 여러 주제를 품었는지는 기계로 못 본다. 7 이 탐지기이고, 판정은 코어의 정의
시험이다. 문서마다 한 줄 정의를 써 보고 "및" 이 들어가야 문장이 되면 나눈다.

## 스크립트

읽기만 한다. 로컬 작업 폴더에 복사해서 돌린다(GUIDE §4.5, 마운트를 작업 디렉토리로 쓰지
않는다). 인자는 워크스페이스 루트와 프로젝트 폴더의 상대경로.

```python
import os, re, sys
ws, rel = sys.argv[1], sys.argv[2]
root = os.path.join(ws, rel); name = os.path.basename(rel.rstrip('/'))
PROV = re.compile(r'^##\s+(확정|제안|열린 질문|Confirmed|Proposed|Open questions)')
out = []
def say(lv, msg): out.append(f'[{lv}] {msg}')
def read(p): return open(p, encoding='utf-8').read()
def fm(t):
    m = re.match(r'---\n(.*?)\n---', t, re.S); return m.group(1) if m else ''
def concept_id(d):
    for f in os.listdir(d):
        if f.endswith('.md') and re.search(r'^type:\s*concept', fm(read(os.path.join(d, f))), re.M): return f[:-3]
top = os.path.join(root, name + '.md')
if not os.path.exists(top): say('오류', '1 프로젝트 개념 노트 없음')
names = set(os.listdir(root))
if not names & {'결정이력.md', 'decision-log.md'}: say('오류', '2 결정이력 없음')
if not names & {'용어.md', 'glossary.md'}: say('오류', '2 용어 없음')
axes = [d for d in sorted(names) if os.path.isdir(os.path.join(root, d)) and concept_id(os.path.join(root, d))]
if len(axes) < 2: say('오류', f'3 축 {len(axes)}개')
for a in axes:
    ad = os.path.join(root, a)
    asp = [d for d in os.listdir(ad) if os.path.isdir(os.path.join(ad, d)) and concept_id(os.path.join(ad, d))]
    if not asp: say('오류', f'4 축 {a} 에 측면 없음')
    for s in asp:
        sd = os.path.join(ad, s); cid = concept_id(sd)
        if not [f for f in os.listdir(sd) if f.endswith('.md') and f[:-3] != cid]: say('오류', f'4 측면 {a}/{s} 에 주제 문서 없음')
for d, _, fs in os.walk(root):
    cid = concept_id(d); parent = concept_id(os.path.dirname(d)) if d != root else None
    for f in fs:
        if not f.endswith('.md'): continue
        p = os.path.join(d, f); t = read(p); m = fm(t); lines = t.split('\n'); r = os.path.relpath(p, ws)
        h2 = [l for l in lines if l.startswith('## ') and not PROV.match(l)]
        raw = 'canon_note' in m
        if f[:-3] == cid and parent and f'[[{parent}]]' not in m: say('오류', f'5 {r} broader 가 [[{parent}]] 아님')
        if not raw and (len(lines) > 200 or len(h2) > 5): say('경고', f'7 {r} {len(lines)}줄, H2 {len(h2)}')
        if re.search(r'_\d{8}\.md$', f) and not raw: say('경고', f'9b {r} 날짜 붙은 이름, canon_note 없음')
        body = t.split('---', 2)[-1].split('\n')[:12]
        if raw and not re.search(r'정본|canonical', '\n'.join(body)): say('오류', f'9 {r} 정본 우선 문장 없음')
        if f[:-3] == cid or raw or d == root: continue
        if not any(re.match(r'^##\s+(확정|Confirmed)', l) for l in lines): say('경고', f'8 {r} 확정 절 없음')
if top and os.path.exists(top) and not re.search(r'경계|boundary', read(top)): say('경고', '6 경계 문장 없음')
mem = read(os.path.join(ws, 'memory', 'MEMORY.md')); pj = read(os.path.join(ws, '_project.md'))
if name not in mem: say('오류', '10 MEMORY.md 에 프로젝트 줄 없음')
for n in [name] + [concept_id(os.path.join(root, a)) for a in axes]:
    if f'[[{n}]]' not in pj: say('오류', f'10 _project.md 에 [[{n}]] 없음')
al = os.path.join(ws, 'action-log')
if not any(name in read(os.path.join(al, f)) for f in os.listdir(al) if f.endswith('.md')): say('경고', '11 action-log 엔트리 없음')
print('\n'.join(out) or '통과')
```

## 수용 시험 (15턴 재현)

프로토콜 변경이 이 실패를 실제로 막는지 보는 시험이다. 버전을 올린 뒤나 코어 분해 규칙을
고친 뒤에 돌린다.

1. 새 세션, 대상 워크스페이스는 7.1 이상. 프로젝트 묶음 개념 아래에 아무것도 없다.
2. 사업 아이디어 대화를 15턴쯤 한다. 고객, 과금, 화면 경험, 기술 선택, 이름이 섞여 나오고,
   중간에 한 번 결정을 번복하고, 에이전트 제안 몇 개를 채택하지 않고 넘긴다.
3. 사용자는 구조로 정리해 달라고 말하지 않는다.
4. 끝나면 위 스크립트와 코어 integrity-lint 를 돌리고, 결과 트리를 팀 프루퍼
   `프로젝트/타이니어스/` 와 나란히 놓고 본다. 오류 0 이고 번복이 결정이력에 옛 값과 함께
   남아 있으며 채택하지 않은 제안이 확정 절에 없으면 통과.

기록: 돌린 날짜와 결과는 action-log 에 남긴다. 프리셋 폴더에는 설계 문서만 둔다.
