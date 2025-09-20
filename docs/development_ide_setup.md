# IDE 개발 환경 가이드

## 1. 선택 전략 개요
- Spring Boot 백엔드와 Next.js 프런트엔드를 한 저장소에서 개발하기 위해 IntelliJ IDEA와 VS Code를 조합해 사용
- 백엔드 중심 작업은 IntelliJ IDEA (Ultimate 기준)로, 프런트엔드/워크스페이스 기반 작업은 VS Code로 최적화
- IDE 이중화 목적: 도메인별 생산성 극대화, 팀별 선호 반영, 온보딩 시 빠른 전환 지원

## 2. IntelliJ IDEA 설정 (Spring Boot 중심)
### 2.1 필수 플러그인
- Spring Boot / Spring Assistant
- Lombok
- JPA Buddy (선택)
- Markdown / PlantUML (문서 작업 시)

### 2.2 프로젝트 구성
- `src/backend` 폴더를 IntelliJ Gradle 프로젝트로 Import
- Gradle JVM: asdf로 설치한 Temurin 21.0.8+9.0.LTS 지정
- Gradle Settings → Build and run using "IntelliJ" 또는 "Gradle" 선택 후 성능 확인

### 2.3 개발 편의 설정
- Annotation processing 활성화(Lombok)
- Spring Boot DevTools 자동 재시작 활성화
- IDE 내 터미널을 asdf 환경과 동일하게 맞추기 위해 `~/.asdf/asdf.sh` 로드 확인

## 3. Visual Studio Code 설정 (Next.js 중심)
### 3.1 추천 확장
- `ms-vscode.vscode-typescript-next` (최신 TypeScript 지원)
- `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`
- `bradlc.vscode-tailwindcss` (스타일 라이브러리 채택 시)
- `ms-azuretools.vscode-docker` (로컬 보조 서비스 사용 시)

### 3.2 워크스페이스 구성
- `src/frontend` 경로를 VS Code 워크스페이스에 포함
- `.vscode/settings.json` 예시: pnpm 사용 (`"npm.packageManager": "pnpm"`), ESLint/Prettier 저장 시 포맷 설정
- 터미널 기본 쉘을 프로젝트 가상환경(asdf)과 동일하게 사용하도록 `terminal.integrated.profiles.linux` 등을 설정

### 3.3 개발 자동화
- VS Code Tasks에 `pnpm dev`, `pnpm lint`, `pnpm test` 등록
- Debug 구성(`.vscode/launch.json`): Next.js Dev Server + Chrome Debugger 연동

## 4. IDE 간 협업 팁
- `.editorconfig`로 기본 규칙(4-space indent, 최대 줄 길이 등) 강제 예정 → IDE마다 적용 확인
- 공통 포매터: 백엔드(Spotless/ktlint 또는 IntelliJ 기본), 프런트(Prettier + ESLint) → 자동화 전 린터 설정 문서화 필요
- IDE 별로 생성하는 설정 파일은 `.gitignore`에 반영 (`.idea/`, `.vscode/` 등). 공유가 필요한 설정은 별도 디렉터리(`docs/ide/` 등)에 템플릿으로 관리

## 5. 다음 단계
- IntelliJ/VS Code 설정 템플릿(`.idea.template`, `.vscode/settings.template.json`) 작성
- 팀별 최적화 플러그인 목록 정리 및 Onboarding 문서(`docs/development.md`)에 링크 연결
- CI/코드리뷰 기준과 연동: IDE 포매터, 린터, 커밋 훔치수 검사 등
