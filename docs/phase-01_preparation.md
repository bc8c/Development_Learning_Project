# Phase 1: 준비 단계

## 1. 런타임 및 버전 관리 기반 구축
- [x] 1.1 `asdf` v0.14.0 설치 및 전역 초기화(`~/.asdf`, 셸 init 스니펫 추가)
- [x] 1.2 `asdf` 플러그인 등록: `nodejs`, `java`
- [x] 1.3 Java/Node 표준 버전 설치: Temurin 21.0.8+9.0.LTS, Node 22.12.0
- [x] 1.4 프로젝트 루트 `.tool-versions`로 런타임 고정 (`nodejs 22.12.0`, `java temurin-21.0.8+9.0.LTS`)
- [x] 1.5 IDE 가이드 정리 (`docs/development_ide_setup.md`)

## 2. 패키지 매니저 전략 및 스크립트 자동화
- [x] 2.1 루트 `package.json` 생성, `packageManager: "pnpm@9.12.1"`로 버전 고정
- [x] 2.2 `resolve_pnpm_version`을 포함한 `scripts/bootstrap.sh` 작성: asdf 설치·플러그인·런타임 구성 + npm 전역 설치로 pnpm 준비 (package.json 버전 참조)
- [x] 2.3 공통 로깅 스크립트(`scripts/common/logging.sh`) 도입 및 색상 로그 적용
- [x] 2.4 루트 `package.json`에 스켈레톤 pnpm 스크립트(`install`, `dev`, `lint`, `test`) 정의

## 3. 워크스페이스 설계
- [x] 3.1 `pnpm-workspace.yaml` 작성 (`src/frontend`, `scripts` 경로 포함)
- [x] 3.2 추가 패키지(예: `src/backend`) 편입 여부 검토 및 워크스페이스 업데이트 (src/backend 포함, 디렉터리 생성)
- [x] 3.3 워크스페이스별 `package.json` 스켈레톤 마련 (`src/frontend`, `src/backend`에 기본 스크립트 추가)

## 4. 자동화 및 CI 파이프라인 초안
- [x] 4.1 GitHub Actions 워크플로(`.github/workflows/ci.yml`) 작성: Node 22.12.0 설정 → `scripts/bootstrap.sh` 실행 → `pnpm install` → 프런트엔드 lint/test 시도 → 버전 출력
- [ ] 4.2 CI용 캐시 전략 정의 (pnpm store, Gradle 등)
- [ ] 4.3 CI 실패 시 알림 정책 정의
- [ ] 4.4 백엔드 빌드/테스트 스텝 연동 (Gradle, JUnit 등)

## 5. 저장소 구조 및 문서/환경 정리 (남은 작업)
- [ ] 5.1 기본 디렉터리 구조(`src/`, `tests/`, `docs/`, `scripts/` 등) 설계 및 문서화
- [ ] 5.2 `.editorconfig`, `.gitignore`, `LICENSE`, `README.md` 스켈레톤 작성
- [ ] 5.3 초기 커밋 전략과 브랜치 네이밍 규칙 정리
- [ ] 5.4 VS Code 워크스페이스 설정 작성 및 공유
- [ ] 5.5 개발용 보조 서비스(Docker Compose 등) 로드맵 수립
- [ ] 5.6 환경 변수 관리 전략(`.env.local`, `docs/configuration.md`) 초안 작성
- [ ] 5.7 테스트 전략(백엔드 JUnit5/AssertJ, 프런트 Jest/RTL) 및 커버리지 기준 수립
- [ ] 5.8 시스템 아키텍처 다이어그램 템플릿 및 개발 가이드 문서 초안 작성
