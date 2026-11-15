---
type: System
slug: {{title}}
name: {{title}}
aliases: []
kind:
tier:
owner:
repo:
runbook:
dashboards: []
purpose:
description:
tags: []
sources: []
links:
  ownedBy: []
  dependsOn: []
  oncall: []
updated: {{date:YYYY-MM-DD}}
---

# {{title}}

kind: service / datastore / pipeline / infra / dependency / tool
tier: critical / important / supporting

## 무엇을 하는가 - purpose

## 소유 팀 - ownedBy

Team 을 가리킨다. 사람을 넣지 않는다. 사람을 소유자로 걸면 그 사람이 떠날 때 소유가
사라진다.

`kind: dependency` 로 팀이 소유하지 않는 외부를 적을 때는 가짜 Team 인스턴스를 만들지
말고 `purpose` 에 공급자를 적는다.

## 무엇에 기대는가 - dependsOn

**의존은 소비하는 쪽에 적는다.** 이 시스템이 쓰는 것을 여기 나열한다. 제공하는 쪽에
소비자 목록을 두면 새 소비자가 생길 때마다 제공자 노트를 고쳐야 한다.

아는 만큼만 적는다. 틀린 의존 그래프는 없는 것보다 나쁘다. 장애 때 그것을 보고
움직이기 때문이다.

## 여기가 죽으면 뭐가 같이 죽나

여기 손으로 적지 않는다. 역방향은 전문 검색으로 뽑는다.
`grep -rl '\[\[{{title}}\]\]' objects/systems/*.md`

## 지금 당번 - oncall

이 프리셋에서 사람을 가리키는 유일한 소유성 링크다. 시점성이 본질이라 사람이 맞다.
로테이션 자체는 Practice 에 적고 여기는 현재 당번 한 사람만 둔다.

## 장애 대응 - runbook

Practice 를 가리킨다. `tier: critical` 인데 여기가 비어 있으면 [[team-ops-lint]] 가
잡는다.

## 관측 - dashboards

관측 지점 주소는 `dashboards` 에 둔다. 이 시스템을 보는 지표는 여기 적지 않는다.
정본은 Metric 쪽 `observes` 다.
`grep -rl '\[\[{{title}}\]\]' objects/metrics/`

## 장애 이력

여기 손으로 적지 않는다. Incident 가 `affects` 로 이 노트를 가리킨다.
`grep -rl '\[\[{{title}}\]\]' objects/incidents/`

## 메모
