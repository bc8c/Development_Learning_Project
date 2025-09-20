# GitHub Actions 개요

- **Subject**: ci_cd
- **Sub-category**: github_actions
- **Updated**: 2025-09-20
- **Tags**: github_actions, workflow, automation

## Overview
- GitHub Actions는 GitHub 리포지토리 이벤트를 기반으로 워크플로를 자동 실행하는 Continuous Integration/Continuous Delivery(CI/CD, 지속적 통합/지속적 배포) 플랫폼입니다.
- 워크플로는 YAML로 정의하며, 하나 이상의 작업(job)과 단계(step)로 구성되어 다양한 자동화 파이프라인을 설계할 수 있습니다.

## Insights
- 워크플로는 `on` 트리거, `jobs`, `steps` 세 축으로 구조화되며, 각 작업은 독립적인 가상 환경에서 병렬 실행이 가능합니다.
- 하나의 리포지토리 안에 여러 워크플로 파일을 둘 수 있습니다. 예를 들어 `ci.yml`, `lint.yml`, `deploy.yml` 세 파일이 모두 `pull_request` 이벤트를 듣도록 설정하면, PR이 열릴 때 세 워크플로가 모두 따로 실행되어 각자 필요한 검사를 수행합니다.
- `actions/checkout`, `actions/setup-*` 와 같은 공식 액션을 활용하면 코드 체크아웃, 런타임 설치를 최소 구성으로 구현할 수 있습니다.
- 의존성 설치 시간을 단축하기 위해 `actions/cache` 또는 `setup-*` 액션의 내장 캐시 옵션을 결합하는 전략이 널리 사용됩니다.
- 시크릿은 GitHub Secrets(GitHub 비밀 변수)에 저장하며 `${{ secrets.* }}` 구문으로 주입해 민감 정보를 보호합니다.

## Details

### 워크플로 처리 개요
- GitHub는 리포지토리 이벤트를 감지하면 해당 워크플로를 큐에 넣고, 지정된 실행 환경(예: `ubuntu-latest`)을 가진 가상 머신 또는 컨테이너를 할당합니다.
- 각 워크플로는 독립적인 런너에서 수행되며, `jobs` 단위로 병렬 또는 순차 실행을 선택할 수 있습니다.
- 작업이 완료되면 결과(성공/실패, 로그, 아티팩트)가 GitHub로 전송되고, 설정된 알림이나 후속 액션이 동작합니다.

### 트리거(on 블록) 구성
- 워크플로 파일 위치는 `.github/workflows/*.yml`이며, 브랜치, 태그, Pull Request 등 다양한 이벤트를 `on` 블록에서 지정할 수 있습니다.
- `on` 블록에는 워크플로를 트리거할 이벤트를 정의하며, `push`, `pull_request`, `schedule` 등 단일 이벤트 또는 복수 이벤트를 동시에 명시할 수 있습니다.
- 예시:
  ```yaml
  on:
    push:
      branches: [ main, release/* ]
    pull_request:
      paths:
        - 'src/**'
        - 'tests/**'
    schedule:
      - cron: '0 2 * * 1'
    workflow_dispatch:
      inputs:
        run_mode:
          type: choice
          options: [ quick, full ]
          default: quick
          description: '실행 모드 선택'
  ```
### 작업(job)과 단계(step) 구성
- 작업(job)은 `runs-on` 으로 실행 환경을 정의하고, 단계(step)는 `uses`(액션 호출) 또는 `run`(셸 스크립트 실행) 두 형태로 작성합니다.
- 런타임 설정 예시는 다음과 같습니다.
  ```yaml
  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - name: Checkout
          uses: actions/checkout@v4
        - name: Set up Node
          uses: actions/setup-node@v4
          with:
            node-version: '22.12.0'
            cache: 'pnpm'
            cache-dependency-path: 'pnpm-lock.yaml'
  ```
### 캐시 및 데이터 공유 전략
- 캐시 키는 운영체제, 잠금 파일 해시 등으로 구성해 변경 시 자동 무효화되도록 설계합니다.
- 워크플로 간 데이터 전달은 아티팩트 업로드/다운로드 또는 워크플로 출력(`outputs`)을 활용합니다.
### 실행 흐름 예시
- 다음 mermaid 시퀀스 다이어그램은 Pull Request 이벤트 발생 시 워크플로가 실행되는 전체 흐름을 보여 줍니다.
  ```mermaid
  sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant Runner as Actions Runner
    participant Slack as Slack Webhook
    Dev->>GH: Push commits / open PR
    GH-->>Runner: Dispatch workflow_run event
    Runner->>Runner: Checkout repository
    Runner->>Runner: Set up runtime & restore caches
    Runner->>Runner: 실행 단계 (lint/test/build)
    Runner-->>GH: Report job conclusion
    GH-->>Slack: Send failure notification (if any)
  ```

## Applications
- 멀티 런타임 프로젝트에서 Node, Python, Java 등을 조합해 빌드·테스트·배포 파이프라인을 자동화합니다.
- 분기별 배포 태그 생성, 패키지 릴리스, 컨테이너 이미지 빌드와 같은 지속적 배포(CD) 프로세스를 구성할 수 있습니다.
- 리포지토리 관리 업무(레이블 자동화, 이슈 triage 등)를 예약(workflow_dispatch, schedule) 기반으로 처리합니다.

## Resources
- [GitHub Actions 공식 문서](https://docs.github.com/actions)
- [GitHub Actions 마켓플레이스](https://github.com/marketplace?type=actions)
- [actions/cache 리포지토리](https://github.com/actions/cache)

## Related Topics
- [트리거_workflow_dispatch](트리거_workflow_dispatch.md)
- [트리거_schedule](트리거_schedule.md)
- [트리거_repository_dispatch](트리거_repository_dispatch.md)
