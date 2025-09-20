# 트리거_schedule

- **Subject**: ci_cd
- **Sub-category**: github_actions
- **Updated**: 2025-09-20
- **Tags**: schedule, cron, github_actions

## Overview
- `schedule` 트리거는 지정한 cron 표현식에 따라 GitHub Actions 워크플로를 주기적으로 실행합니다.
- 코드 변경 없이도 정기 점검, 야간 배치, 유지보수 스크립트 등을 자동화할 수 있습니다.

## Insights
- cron 표현식은 UTC 기준으로 평가되며 `분 시 일 월 요일` 다섯 필드를 사용합니다.
- 한 워크플로에서 여러 개의 `schedule` 항목을 정의해 서로 다른 주기(예: 일간, 주간)를 병행할 수 있습니다.
- cron 표현식은 최소 5분 간격이 권장되며, GitHub는 지연 실행을 대비해 최대 한 시간까지 오차가 있을 수 있습니다.
- `workflow_dispatch`와 함께 사용하면 정기 실행 외에도 수동 실행을 병행할 수 있어 운영 유연성이 높아집니다.

## Details

### cron 표현식 구성
- 기본 형식: `분 시 일 월 요일`
- 예시:
  ```yaml
  on:
    schedule:
      - cron: '0 2 * * 1'       # 매주 월요일 02:00 (UTC)
      - cron: '30 6 * * *'      # 매일 06:30 (UTC)
  ```
- 요일은 `0` 또는 `7`이 일요일을 의미하며, 쉼표로 복수 값을 지정할 수 있습니다.
- 현지 시간대와 차이가 있으므로 필요 시 `TZ` 환경 변수를 단계에서 설정하거나, cron을 작성할 때 UTC 기준으로 계산합니다.

### 주의사항과 제한
- 동일한 cron 표현식이라도 GitHub 인프라 상태에 따라 실행이 약간 지연될 수 있으며, 중복 실행을 방지하기 위해 작업 내에서 록(lock) 또는 상태 체크가 필요할 수 있습니다.
- fork 리포지토리에서는 일시 중지되거나 제한될 수 있으므로 주 리포지토리에서 관리하는 것이 안전합니다.
- 장시간 실행 작업은 비용과 런너 점유를 고려해 태그별 런너나 자체 호스팅 런너로 분리할 수 있습니다.

### 배치 작업 패턴
- 점검: 의존성 업데이트, 취약점 스캔, 로그 정리 등을 야간에 자동화합니다.
- 백업: 주기적으로 아티팩트나 데이터베이스 스냅샷을 생성하고 외부 스토리지에 업로드합니다.
- 리포트: 빌드 통계나 메트릭을 계산해 슬랙/이메일로 전송합니다.

### 실행 예시
- 매주 월요일 릴리스 브랜치 동기화, 종속성 감사, 코드 포맷터 검사를 수행하는 워크플로 예시입니다.
  ```yaml
  name: Weekly Maintenance

  on:
    schedule:
      - cron: '0 1 * * 1'  # 매주 월요일 01:00 UTC

  jobs:
    sync-release:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
          with:
            fetch-depth: 0
        - name: Sync main -> release
          run: |
            git config user.name 'actions-bot'
            git config user.email 'actions@github.com'
            git checkout release
            git merge --ff-only origin/main
            git push origin release

    dependency-audit:
      runs-on: ubuntu-latest
      needs: sync-release
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: '22.12.0'
        - run: pnpm install --frozen-lockfile
        - run: pnpm audit --prod

    lint-format:
      runs-on: ubuntu-latest
      needs: sync-release
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: '22.12.0'
        - run: pnpm install --frozen-lockfile
        - run: pnpm lint
        - run: pnpm format --check
  ```

### 실행 흐름
- 다음 mermaid 순서도를 통해 `schedule` 트리거가 동작하는 절차를 요약합니다.
  ```mermaid
  flowchart TD
    A[Cron Scheduler] --> B[이벤트 생성]
    B --> C[Actions Runner 할당]
    C --> D[주기적 작업 실행]
    D --> E[결과 보고 및 알림]
  ```

## Applications
- 매주 월요일 릴리스 브랜치 동기화, 종속성 감사, 코드 포맷터 적용 여부 검사 등을 자동으로 수행합니다.
- 새벽 시간대에 장시간 통합 테스트를 돌려 업무 시간의 CI 대기 시간을 줄입니다.
- 서버 헬스체크나 외부 API 모니터링을 일정 주기로 실행해 SLA 위반을 조기 감지합니다.

## Resources
- [schedule 이벤트 공식 문서](https://docs.github.com/actions/using-workflows/events-that-trigger-workflows#schedule)
- [cron 표현식 도우미](https://crontab.guru/)
- [워크플로 시간대 관련 가이드](https://docs.github.com/actions/using-jobs/using-environment-variables#default-environment-variables)

## Related Topics
- [트리거_GitHub Actions 개요](트리거_GitHub Actions 개요.md)
- [트리거_workflow_dispatch](트리거_workflow_dispatch.md)
- [트리거_repository_dispatch](트리거_repository_dispatch.md)
