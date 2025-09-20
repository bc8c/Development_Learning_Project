# pre-commit 가이드

- **Subject**: tooling
- **Sub-category**: pre_commit
- **Updated**: 2025-09-20
- **Tags**: pre-commit, git, hooks

## Overview
- pre-commit은 Git 훅을 선언형으로 관리해 커밋 전에 자동 검사를 실행하게 해 주는 CLI 툴이다.
- `.pre-commit-config.yaml`에 정의한 검사 목록을 커밋 시점마다 실행해 품질을 일관되게 유지할 수 있다.

## Insights
- Git은 `git commit`을 실행할 때 `.git/hooks/pre-commit` 파일을 호출하며, pre-commit CLI가 이 지점을 가로채 등록한 훅을 순서대로 실행한다.
- 각 훅은 독립된 실행 환경에서 동작하며 실패 시 커밋이 중단되고 오류가 출력된다.
- `pre-commit install`은 훅을 `.git/hooks/pre-commit`에 연결하고, `pre-commit run`은 훅을 수동 실행한다.
- `--hook-type` 옵션으로 `pre-commit`(커밋 직전), `pre-push`(푸시 직전), `commit-msg`(메시지 검사) 등 원하는 시점에 훅을 설치할 수 있다.

## Details

### 작동 흐름
- 전체 흐름: Git → `.git/hooks/pre-commit` → pre-commit CLI → 훅 목록 로딩 → 훅별 실행 → 성공 시 커밋 진행, 실패 시 중단.
- 순서도:
  ```mermaid
  flowchart TD
    A[git commit] --> B[.git/hooks/pre-commit]
    B --> C[pre-commit CLI]
    C --> D[훅 목록 로딩]
    D --> E{훅 실행}
    E -->|성공| F[다음 훅]
    E -->|실패| G[커밋 중단 & 메시지]
    F --> H[모든 훅 완료]
    H --> I[커밋 계속]
  ```

### 훅 설치 원리
- `python -m pre_commit install --hook-type pre-commit` 명령은 파이썬으로 pre-commit CLI를 실행해 `.git/hooks/pre-commit`에 래퍼 스크립트를 만든다.
- `--hook-type`은 설치 대상 훅을 지정하며, 여러 훅을 추가하려면 옵션을 반복한다. 기본은 `pre-commit`이다.
- 훅을 설치한 후 설정이 바뀌면 `pre-commit install`을 다시 실행해 최신 상태로 유지한다.

### 기본 설정 절차
1. `.pre-commit-config.yaml`에 실행할 훅을 선언한다.
2. `pre-commit install [--hook-type ...]`으로 훅을 설치한다.
3. `pre-commit run --all-files`로 수동 실행하거나 커밋을 시도해 자동 실행 여부를 확인한다.
4. 훅 버전을 최신화하려면 `pre-commit autoupdate`를 실행한다.

### 설정 예시
```yaml
repos:
  - repo: local
    hooks:
      - id: update-learning-index
        name: Update learning index dates
        entry: scripts/pre-commit/hooks/update_learning_index_dates.py
        language: system
        types: [markdown]
        pass_filenames: false
```

## Applications
- 커밋 전에 문서·코드 검사를 자동 실행해 품질을 유지한다.
- 팀원 간 동일한 검사 파이프라인을 공유해 스타일과 정책을 강제한다.
- CI 이전 단계에서 사소한 오류를 잡아 빌드 시간을 절약한다.

## Resources
- [pre-commit 공식 문서](https://pre-commit.com/)
- [Hooks and configuration](https://pre-commit.com/#hooks)
- [Conventional Commit 소개](https://www.conventionalcommits.org/)

## Related Topics
- [tooling 학습 노트 인덱스](../index.md)
- [GitHub Actions 개요](../../ci_cd/github_actions/GitHub%20Actions%20개요.md)
