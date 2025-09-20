# 트리거_workflow_dispatch

- **Subject**: ci_cd
- **Sub-category**: github_actions
- **Updated**: 2025-09-20
- **Tags**: workflow_dispatch, manual_trigger, github_actions

## Overview
- `workflow_dispatch`는 GitHub Actions 워크플로를 GitHub UI에서 사용자가 수동으로 실행하거나 API를 통해 트리거할 수 있게 해 주는 수동 실행용 이벤트입니다.
- 입력 파라미터를 정의해 실행 시점에 동적인 옵션을 받을 수 있으며, 하나의 워크플로에서 다양한 실행 모드를 지원할 수 있습니다.

## Insights
- 입력 값은 Action Runner에서 `github.event.inputs` 경로로 접근하며 문자열 형태로 전달됩니다.
- `type`, `default`, `required` 등을 활용해 UI에서 선택형, 텍스트 입력형 등의 사용자 경험을 제어할 수 있습니다.
- 조건문(`if`)과 결합하면 동일 워크플로 내에서 입력 값에 따라 다른 단계 또는 잡을 실행할 수 있습니다.
- REST API 또는 GitHub CLI(`gh workflow run`)를 통해서도 동일한 입력 세트를 전달할 수 있어 자동화 파이프라인과 연계하기 용이합니다.

## Details

### 트리거 선언과 입력 정의
- `on.workflow_dispatch` 블록은 다중 입력을 정의할 수 있으며, 입력값은 모두 문자열로 전달됩니다.
- 예시:
  ```yaml
  on:
    workflow_dispatch:
      inputs:
        run_mode:
          type: choice
          options: [ quick, full ]
          default: quick
          description: '실행 모드 선택'
        notes:
          description: '이번 실행에 대한 간단한 메모'
          required: false
  ```
- `type` 필드는 입력 UI의 형태를 정의합니다. 다음 옵션을 지원합니다.
  - `choice`: 미리 정의된 옵션 중 하나를 선택합니다.
  - `boolean`: 체크박스로 `true` 또는 `false` 값을 전달합니다.
  - `environment`: 등록된 환경(Environment) 목록에서 선택합니다.
  - `string`(기본값): 자유 입력 텍스트 필드입니다.

### 입력 값 활용 패턴
- 실행 중에는 `${{ github.event.inputs.run_mode }}` 형태로 값을 참조합니다.
- 조건 분기를 활용한 예:
  ```yaml
  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Run quick tests
          if: ${{ github.event.inputs.run_mode == 'quick' }}
          run: pnpm test --filter quick
        - name: Run full tests
          if: ${{ github.event.inputs.run_mode == 'full' }}
          run: pnpm test
  ```
- 문자열 비교만 지원하므로 숫자나 불리언 처리가 필요하면 셸 스크립트에서 후처리합니다.

### CLI 및 API 연동
- GitHub CLI 예시:
  ```bash
  gh workflow run "CI" \
    --ref main \
    --raw-field run_mode=full \
    --raw-field notes="릴리스 후보 검증"
  ```
- REST API 호출 시에는 `POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches` 엔드포인트를 사용하며, JSON 본문에 `ref`와 `inputs`를 전달합니다.
  ```json
  {
    "ref": "main",
    "inputs": {
      "run_mode": "full",
      "notes": "릴리스 후보 검증"
    }
  }
  ```

### 보안 고려사항
- 입력 값은 시크릿이 아니므로 민감한 정보를 직접 입력 값으로 받지 않도록 설계합니다.
- 민감 정보가 필요한 경우 `repository dispatch`와 시크릿을 조합하거나, 실행 단계에서 별도 시크릿을 로딩합니다.

### 실행 흐름
- 다음 mermaid 순서도를 통해 사용자가 UI에서 워크플로를 실행할 때의 절차를 정리했습니다.
  ```mermaid
  flowchart TD
    A[사용자]
    B[실행 입력 작성]
    C[workflow_dispatch 이벤트]
    D[Actions Runner 큐잉]
    E[입력 값 기반 단계 분기]
    F[실행 결과 보고]

    A -->|Run workflow 클릭| B
    B --> C
    C --> D
    D --> E
    E --> F
  ```

## Applications
- 배포 승인 후 수동으로 릴리스 파이프라인을 실행해 QA 단계와 운영 배포 단계를 분리할 수 있습니다.
- 긴 테스트를 수동으로만 실행해 CI 비용을 절감하고, 필요 시 전체 테스트(full 모드)를 요청할 수 있습니다.
- 외부 시스템(CDP, 챗봇 등)에서 GitHub API를 호출해 특정 시점에 파이프라인을 트리거하도록 연동할 수 있습니다.

## Resources
- [workflow_dispatch 공식 문서](https://docs.github.com/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch)
- [GitHub CLI `gh workflow run`](https://cli.github.com/manual/gh_workflow_run)
- [Actions REST API 레퍼런스](https://docs.github.com/rest/actions/workflows#create-a-workflow-dispatch-event)

## Related Topics
- [트리거_GitHub Actions 개요](트리거_GitHub Actions 개요.md)
- [트리거_schedule](트리거_schedule.md)
- [트리거_repository_dispatch](트리거_repository_dispatch.md)
