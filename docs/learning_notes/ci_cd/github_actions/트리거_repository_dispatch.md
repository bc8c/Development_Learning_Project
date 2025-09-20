# 트리거_repository_dispatch

- **Subject**: ci_cd
- **Sub-category**: github_actions
- **Updated**: 2025-09-20
- **Tags**: repository_dispatch, external_trigger, github_actions

## Overview
- `repository_dispatch`는 외부 시스템이 GitHub REST API를 호출해 워크플로를 수동으로 실행하도록 만드는 이벤트입니다.
- 웹훅, 배포 파이프라인, 내부 서비스에서 직접 워크플로를 호출할 수 있어 GitHub Actions를 중앙 자동화 허브로 사용할 수 있습니다.

## Insights
- 이벤트 호출 시 `event_type`과 `client_payload`를 함께 전달하며, 워크플로 내부에서는 `github.event.action`, `github.event.client_payload`로 접근합니다.
- 인증에는 GitHub Personal Access Token(PAT) 또는 GitHub App 토큰이 필요하고, 최소 `repo` 권한을 가져야 합니다.
- 조직/엔터프라이즈 규모에서는 GitHub App을 활용해 세분화된 권한 관리와 감사 로그를 확보할 수 있습니다.
- 일정 스케줄과 결합하면 외부 시스템이 상황에 따라 워크플로를 즉시 호출하거나, 내부 승인 절차 후 트리거할 수 있습니다.

## Details

### 이벤트 호출 형식
- REST API 엔드포인트: `POST /repos/{owner}/{repo}/dispatches`
- 예시 요청:
  ```bash
  curl -X POST \       -H "Accept: application/vnd.github+json" \       -H "Authorization: Bearer $GITHUB_TOKEN" \       -H "Content-Type: application/json" \       https://api.github.com/repos/OWNER/REPO/dispatches \       -d '{
             "event_type": "sync-release",
             "client_payload": {
               "target_branch": "release",
               "initiator": "internal-ci"
             }
           }'
  ```
- 워크플로 내부에서는 `${{ github.event.action }}` 값으로 `event_type`, `${{ toJson(github.event.client_payload) }}`로 payload 전체를 확인할 수 있습니다.

### 워크플로 선언과 입력 처리
- `on.repository_dispatch.types`에서 수신할 이벤트 타입을 지정합니다.
- 예시 워크플로:
  ```yaml
  on:
    repository_dispatch:
      types: [sync-release]

  jobs:
    trigger-sync:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Read inputs
          run: |
            echo "Target branch: ${{ github.event.client_payload.target_branch }}"
            echo "Triggered by: ${{ github.event.client_payload.initiator }}"
        - name: Sync branches
          if: ${{ github.event.client_payload.target_branch == 'release' }}
          run: |
            git config user.name 'actions-bot'
            git config user.email 'actions@github.com'
            git checkout release
            git merge --ff-only origin/main
            git push origin release
  ```

### 보안 및 운영 고려사항
- PAT를 사용할 경우 최소 권한의 토큰을 발급하고, 만료 주기를 관리합니다.
- GitHub App을 사용할 때는 설치 범위(installation)와 권한을 엄격히 제한하고, 감사 로그를 주기적으로 확인합니다.
- 외부 시스템에서 이벤트를 호출할 때 재시도 로직과 실패 알림(Webhook, Slack 등)을 구성해 신뢰성을 확보합니다.

### 활용 시나리오
- 인프라: Terraform, Ansible 등의 외부 자동화 툴이 변경 사항을 감지하면 GitHub Actions로 검증 파이프라인을 호출합니다.
- 승인 프로세스: 사내 포털에서 배포 승인 후 `repository_dispatch`를 호출해 실제 배포 워크플로를 시작합니다.
- 다중 리포지토리 연동: 메인 리포의 업데이트를 감지한 뒤 다른 리포지토리로 `repository_dispatch`를 보내 빌드/배포를 연이어 실행합니다.

### 실행 흐름
- 다음 mermaid 순서도는 외부 시스템이 이벤트를 호출해 워크플로가 실행되는 과정을 보여 줍니다.
  ```mermaid
  sequenceDiagram
    participant Ext as External System
    participant GH as GitHub API
    participant Runner as Actions Runner
    Ext->>GH: POST /dispatches (event_type, payload)
    GH-->>Runner: Trigger repository_dispatch
    Runner->>Runner: Checkout & process payload
    Runner-->>GH: Report status
  ```

## Applications
- 외부 사용자 승인 후 즉시 배포 파이프라인을 호출하거나, 다중 환경(스테이징/프로덕션) 전환을 자동화합니다.
- 사내 데이터 파이프라인에서 특정 조건이 만족되면 GitHub Actions로 후속 데이터 처리 작업을 실행합니다.
- 다른 CI/CD 시스템(예: Jenkins)과 연동해, GitHub Actions가 특정 단계만 담당하도록 역할을 분담합니다.

## Resources
- [repository_dispatch 공식 문서](https://docs.github.com/actions/using-workflows/events-that-trigger-workflows#repository_dispatch)
- [GitHub REST API: Create a repository dispatch event](https://docs.github.com/rest/repos/repos#create-a-repository-dispatch-event)
- [GitHub App 인증 가이드](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app)

## Related Topics
- [트리거_GitHub Actions 개요](트리거_GitHub Actions 개요.md)
- [트리거_workflow_dispatch](트리거_workflow_dispatch.md)
- [트리거_schedule](트리거_schedule.md)
