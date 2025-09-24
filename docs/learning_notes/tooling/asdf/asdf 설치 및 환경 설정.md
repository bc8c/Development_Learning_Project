# asdf 설치 및 환경 설정

- **Subject**: tooling
- **Sub-category**: asdf
- **Updated**: 2025-09-24
- **Tags**: asdf, setup, installation

## Overview
이 문서는 macOS, Linux 등 POSIX 계열 환경에서 asdf를 설치하고 셸 초기화, 플러그인 추가, 런타임 동기화까지 완료하기 위한 절차를 정리한다. 기본 흐름은 Git으로 asdf를 설치한 뒤 셸에 초기화 스니펫을 추가하고, 필요한 플러그인과 버전을 `.tool-versions`로 고정하는 것이다.

## Insights
- asdf 본체는 Git 저장소(`~/.asdf`)를 그대로 사용하므로 버전 고정은 특정 태그나 브랜치를 체크아웃하는 방식으로 이뤄진다.
- 셸 초기화 파일에 `~/.asdf/asdf.sh`를 로드하지 않으면 shim이 PATH에 잡히지 않아 명령이 실패할 수 있다.
- 플러그인 설치와 버전 설치는 별도 단계이며, 플러그인이 없으면 `asdf install`이 실패한다.
- `.tool-versions`를 통해 여러 런타임 버전을 한번에 선언하면 `asdf install`이 일괄 처리해 준다.
- 새로운 실행 파일이 추가되면 `asdf reshim`으로 shim을 최신 상태로 유지해야 한다.

## Details
### 1. asdf 본체 설치
1. Git을 이용해 원하는 버전으로 클론한다.
   ```bash
   git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
   ```
2. 이미 설치되어 있다면 `git -C ~/.asdf fetch --depth=1 origin v0.14.0 && git -C ~/.asdf checkout v0.14.0`으로 버전을 동기화한다.
3. 셸 세션에서 `asdf --version`으로 설치 여부를 점검한다.

### 2. 셸 초기화 및 자동 완성
`shell`이 시동될 때 asdf를 로드하도록 `.bashrc`, `.zshrc` 등 사용자 셸 초기화 파일에 아래 스니펫을 추가한다.
```bash
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"  # bash: 자동 완성
```
Zsh일 경우 `~/.asdf/completions/asdf.zsh`를 사용하며, Fish는 별도 함수 파일(`~/.config/fish/conf.d/asdf.fish`)을 복사해야 한다. 변경 후 새 셸을 열거나 `source ~/.zshrc`와 같이 재적용한다.

### 3. 필수 의존성 및 도구
- macOS: `git`, `curl`, `coreutils`가 설치되어 있어야 한다. Homebrew 사용자라면 `brew install coreutils curl git`으로 기본 패키지를 준비한다.
- Linux: `build-essential`, `libssl-dev`, `zlib1g-dev` 등 런타임마다 필요한 컴파일 도구가 필요할 수 있으므로 플러그인 문서를 미리 확인한다.

### 4. 플러그인 관리
1. 설치 가능한 플러그인 탐색
   ```bash
   asdf plugin list-all | grep python
   ```
2. 플러그인 추가
   ```bash
   asdf plugin add nodejs
   asdf plugin add java https://github.com/halcyon/asdf-java.git
   ```
3. 플러그인 업데이트
   ```bash
   asdf plugin update --all
   ```

### 5. 런타임 설치와 버전 고정
- 원하는 버전을 지정해 설치한다.
  ```bash
  asdf install nodejs 22.12.0
  asdf install python 3.11.9
  ```
- 프로젝트 디렉터리에서 `asdf local`을 사용하면 `.tool-versions` 파일이 생성되거나 갱신된다.
  ```bash
  $ asdf local nodejs 22.12.0 python 3.11.9
  $ cat .tool-versions
  nodejs 22.12.0
  python 3.11.9
  ```
- 전역 기본값은 `asdf global <name> <version>`으로 설정하며, 사용자의 홈 디렉터리에 `~/.tool-versions` 파일이 생성된다.
- `.tool-versions`를 수동으로 편집한 뒤에는 `asdf install`을 다시 실행해 누락된 버전을 설치한다.

### 6. shim 갱신과 실행 확인
- 새 버전이 설치되면 `asdf reshim <name>`으로 shim을 갱신한다. 모든 플러그인에 대해 갱신하려면 `asdf reshim`만 실행하면 된다.
- `asdf where <name>`으로 실제 설치 경로를 찾고, `asdf exec <name> --version`으로 런타임이 올바르게 로드되는지 검증한다.

### 7. 자동화 스크립트와 CI 연동
- 스크립트에서는 `asdf exec`을 사용해 PATH 오염을 방지한다. 예: `asdf exec python -m venv .venv`.
- CI 환경에서는 체크아웃 후 `asdf plugin add --all`과 `.tool-versions`를 기반으로 `asdf install`을 수행한 뒤 필요한 빌드나 테스트를 실행한다.
- 이 저장소에서는 `scripts/bootstrap.sh`가 위 절차를 자동화하여 팀원 환경을 통일한다.

## Applications
- 다언어 프로젝트 온보딩: 저장소 클론 후 `asdf plugin add...`, `asdf install`만으로 필수 런타임을 맞출 수 있다.
- 개인 개발 환경: 전역 설치와 프로젝트별 설치를 분리하여 실험적인 버전을 안전하게 테스트한다.
- CI/CD: 컨테이너나 빌드 에이전트에서 `.tool-versions`를 기반으로 동일한 런타임을 재현해 빌드 편차를 줄인다.

## Resources
- [asdf 설치 가이드](https://asdf-vm.com/guide/getting-started.html)
- [플러그인 관리 문서](https://asdf-vm.com/manage/plugins.html)
- [`scripts/bootstrap.sh`](../../../../scripts/bootstrap.sh)

## Related Topics
- [`asdf 기본 개념`](asdf 기본 개념.md)
- [`pre-commit` 통합 가이드](../pre_commit/pre-commit 가이드.md)
- `direnv` 자동 로드 설정 방법
