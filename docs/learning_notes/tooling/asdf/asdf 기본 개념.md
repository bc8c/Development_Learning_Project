# asdf 기본 개념

- **Subject**: tooling
- **Sub-category**: asdf
- **Updated**: 2025-09-24
- **Tags**: asdf, version-management, plugins

## Overview
asdf는 여러 언어와 CLI 도구의 버전을 프로젝트별로 정확하게 고정하기 위해 설계된 범용 버전 관리자이다. 단일 명령 집합과 선언적 구성 파일을 통해 Node.js, Python, Java뿐 아니라 Terraform, pnpm 같은 도구도 통합적으로 제어할 수 있다.

## Insights
- 플러그인 레지스트리는 Git 저장소 기반이기 때문에 커뮤니티가 새로운 언어·도구를 빠르게 추가할 수 있다.
- `.tool-versions` 파일은 디렉터리마다 필요한 런타임을 선언적으로 명시하며, 상위 디렉터리에서 하위 디렉터리로 상속된다.
- shim 실행 파일은 PATH 상단에 배치되어 실제 바이너리를 호출하기 전에 asdf가 적절한 버전을 결정할 수 있도록 한다.
- `asdf global`은 전역 기본값을, `asdf local`은 특정 디렉터리(프로젝트) 전용 버전을 관리한다.
- `asdf exec <tool>`은 shim 해석을 우회하고 원하는 버전을 직접 실행함으로써 CI나 스크립트에서 일관된 동작을 보장한다.

## Details
### 버전 관리 모델
asdf는 디렉터리 지향 버전 관리를 채택한다. 현재 작업 디렉터리와 그 상위 경로에 존재하는 `.tool-versions` 파일을 탐색하여 가장 가까운 설정을 우선 적용한다. 설정이 없으면 `~/.tool-versions` 또는 `asdf global`로 지정한 전역 구성을 사용하고, 그마저 없으면 시스템 PATH에 있는 기본 실행 파일을 사용한다.

### `.tool-versions` 파일 구조
각 행은 `<플러그인 이름> <버전>` 형태로 구성된다. 예를 들어 `nodejs 22.12.0`과 `python 3.11.9`를 선언하면 해당 디렉터리 이하에서 두 런타임 버전이 자동 활성화된다. `asdf local`을 실행하면 현재 디렉터리에 `.tool-versions`가 생성되거나 기존 파일에 새로운 행이 추가된다.
```bash
$ pwd
/home/user/workspace/sample-app
$ asdf local nodejs 22.12.0 python 3.11.9
$ cat .tool-versions
nodejs 22.12.0
python 3.11.9
```
`.tool-versions`는 텍스트 파일이므로 버전을 바꾸거나 주석(`#`)을 추가해 변경 이력을 남길 수 있다.

### 플러그인 생태계
asdf 본체는 최소한의 기능만 제공하며, 실제 설치·빌드 로직은 플러그인마다 구현되어 있다. 공식 플러그인 목록은 `asdf plugin list-all`로 조회할 수 있고, 사설 플러그인은 Git URL을 명시하여 추가한다. 플러그인 역시 Git 저장소이므로 원하는 버전으로 체크아웃해 테스트하거나 포크하여 내부용 도구를 확장할 수 있다.

### Shim 동작
asdf는 `~/.asdf/shims/<tool>` 경로에 shim 실행 파일을 생성한다. 사용자가 `python`을 호출하면 shim이 먼저 실행되며, 현재 디렉터리의 `.tool-versions`를 읽어 지정된 버전의 실제 바이너리로 위임한다. 새 버전을 설치하거나 제거하면 `asdf reshim <name>`을 실행해 shim을 최신 상태로 갱신해야 한다.

### 명령 체계 요약
- `asdf plugin list`, `asdf plugin list-all`: 설치된/설치 가능한 플러그인 확인
- `asdf list <name>`: 특정 플러그인의 설치된 버전 확인
- `asdf current`: 현재 활성화된 버전 요약 출력
- `asdf where <name>`: 설치 경로 확인 (예: `asdf where nodejs`)
- `asdf uninstall <name> <version>`: 특정 버전 제거
- `asdf plugin update --all`: 모든 플러그인 최신화

## Applications
- 다언어 프로젝트는 `.tool-versions` 하나로 팀 전체 런타임 버전을 통제하고, 하위 디렉터리에서 별도 버전이 필요하면 추가 `.tool-versions`를 배치하여 세분화할 수 있다.
- 개인 개발자는 전역 설정을 유지하되, 실험적인 버전을 특정 디렉터리에서만 사용해 시스템 환경을 오염시키지 않는다.
- CI 환경에서는 `asdf exec <command>`를 활용해 shim 경로 문제를 회피하면서도 `.tool-versions`에 정의된 정확한 버전을 실행할 수 있다.

## Resources
- [asdf 공식 문서](https://asdf-vm.com/guide/getting-started.html)
- [공식 플러그인 목록](https://github.com/asdf-vm/asdf-plugins)
- [플러그인 개발 가이드](https://asdf-vm.com/manage/plugins.html)

## Related Topics
- [`asdf 설치 및 환경 설정`](asdf 설치 및 환경 설정.md)
- [`pre-commit` 통합 가이드](../pre_commit/pre-commit 가이드.md)
- `mise`(asdf 대안) 비교 노트
