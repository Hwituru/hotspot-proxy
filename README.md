<p align="center">
  <img src="design/icon/preview.png" width="420" alt="핫스팟 프록시 앱 아이콘 (라이트 / 다크 / 틴티드)">
</p>

<h1 align="center">핫스팟 프록시</h1>

<p align="center">
  아이폰 개인용 핫스팟에 붙은 기기들이 <b>아이폰의 셀룰러 회선을 프록시로</b> 쓰게 해 주는 iOS 앱.<br>
  HTTP · HTTPS(CONNECT) · SOCKS5(TCP + UDP ASSOCIATE)를 한 포트에서 받습니다.
</p>

<p align="center">
  <img alt="iOS 17+" src="https://img.shields.io/badge/iOS-17%2B-0B8A7D">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5-F05138">
  <img alt="SwiftUI + WidgetKit" src="https://img.shields.io/badge/SwiftUI-WidgetKit-33D6C2">
</p>

---

## 왜 필요한가

일부 요금제나 망은 핫스팟 테더링 트래픽을 따로 구분해 제한합니다. 이 앱은 아이폰 안에서 프록시 서버를 띄웁니다. 핫스팟에 연결된 기기(맥, 아이패드, 노트북)가 이 프록시를 거치면, 트래픽이 아이폰 앱 자신의 트래픽으로 나가게 됩니다.

## 스크린샷

| 메인 (실행 중) | 핫스팟 꺼짐 | 설정 | 온보딩 |
|---|---|---|---|
| <img src="docs/screenshots/main-light.png" width="200"> | <img src="docs/screenshots/nohotspot-light.png" width="200"> | <img src="docs/screenshots/settings-light.png" width="200"> | <img src="docs/screenshots/onboarding-light.png" width="200"> |
| <img src="docs/screenshots/main-dark.png" width="200"> | <img src="docs/screenshots/nohotspot-dark.png" width="200"> | <img src="docs/screenshots/settings-dark.png" width="200"> | <img src="docs/screenshots/onboarding-dark.png" width="200"> |

<img src="docs/screenshots/home-icon.png" width="300" alt="홈 화면의 앱 아이콘">

### 잠금화면 / 홈 위젯

<img src="docs/screenshots/widgets.png" width="420" alt="잠금화면 원형/사각/인라인 위젯과 홈 소형 위젯">

- **잠금화면**은 원형(연결 수와 상태), 사각형(상태, `IP:포트`, 연결·전송량), 인라인(한 줄 상태)을 지원합니다.
- **홈 화면**은 소형 위젯(상태 칩, 접속 주소, 통계, 마지막 갱신 시각)을 지원합니다.
- 위젯을 탭하면 앱이 열립니다. 앱은 상태가 바뀔 때만 위젯을 갱신하므로 배터리 소모가 거의 없습니다.

## 기능

- **상태 히어로** "signal ring"으로 현재 상태를 보여줍니다. 실행 중이면 초록, 핫스팟이 꺼지면 주황, 프록시가 꺼지면 회색, 오류면 빨강입니다.
- **원탭 시작/중지**이며 햅틱 피드백을 줍니다.
- **접속 주소 복사**: 다른 기기에 입력할 `172.20.10.1:8080`을 한 번에 복사합니다.
- **실시간 통계**로 활성 연결, 전송량, 가동 시간을 보여줍니다. 화면이 보일 때만 갱신합니다.
- **연결 안내**는 iPhone/iPad, macOS, Android, Windows별 프록시 설정 방법을 담고 있습니다.
- **Mac 자동 TUN 안내**: `mac/` 스크립트로 시스템 전체 트래픽을 자동으로 프록시에 태웁니다.
- **온보딩**은 핫스팟 켜기, 로컬 네트워크 권한, 백그라운드 유지 원리를 설명합니다.
- 다크 모드, Dynamic Type(접근성 크기 포함), VoiceOver 라벨, 동작 줄이기를 지원합니다.

## 사용법

1. 아이폰에서 **설정 › 개인용 핫스팟 › 다른 사람의 연결 허용**을 켭니다.
2. 앱을 열고 **프록시 시작**을 누릅니다. 기본값으로 실행 시 자동 시작됩니다.
3. 다른 기기를 핫스팟에 연결한 뒤 프록시를 수동으로 설정합니다.
   - 서버는 `172.20.10.1`(앱 화면에 표시)이고 포트는 `8080`입니다.
   - HTTP, HTTPS, SOCKS5 모두 같은 포트를 씁니다.

### Mac: 시스템 전체 자동 프록시 (선택)

`mac/` 디렉터리에는 [sing-box](https://sing-box.sagernet.org) TUN을 이용해 **핫스팟에 붙었을 때만** 모든 트래픽을 아이폰 프록시로 보내는 launchd 구성이 들어 있습니다.

```bash
brew install sing-box
sudo bash mac/install.sh        # 설치 (네트워크 변경 감지 → 자동 on/off)
sudo bash mac/uninstall.sh      # 제거
sudo bash mac/install-tailscale.sh   # (선택) Tailscale을 CLI 데몬으로 전환
```

`hotspot-tun.sh`는 네트워크가 바뀔 때와 30초마다 실행됩니다. 아이폰 핫스팟(`172.20.10.x`)에 붙어 있고 `172.20.10.1:8080`이 응답하면 TUN과 DNS를 켜고, 그렇지 않으면 원래대로 되돌립니다.

## 백그라운드 동작과 배터리

iOS는 백그라운드 앱의 소켓을 오래 살려두지 않습니다. 그래서 이 앱은 **무음 오디오 루프**(8kHz, 30초 단위)로 프로세스를 유지합니다. 다른 앱 소리와 섞이며(`mixWithOthers`) 볼륨은 0입니다. UI 타이머는 화면이 보일 때만 돌고, UDP 흐름은 60초 동안 쉬면 정리됩니다.

> 무음 오디오 백그라운드 모드는 App Store 심사 기준에 맞지 않을 수 있습니다. 이 앱은 개인 사이드로드나 개발자 서명 용도를 전제로 합니다.

## 빌드

```bash
brew install xcodegen
xcodegen generate
open HotspotProxy.xcodeproj
```

- 타깃은 `HotspotProxy`(앱)와 `HotspotProxyWidget`(WidgetKit 확장)입니다.
- 두 타깃은 App Group `group.com.indoyoon.hotspotproxy`로 상태를 공유합니다. 본인 팀으로 빌드할 때는 `project.yml`의 `DEVELOPMENT_TEAM`, 번들 ID, App Group을 바꾸세요.
- 앱 아이콘 원본은 `design/icon/*.svg`이고, 디자인 시스템은 [`DESIGN.md`](DESIGN.md)에 있습니다.

## 구조

```
Sources/
  App.swift              앱 진입점, 딥링크 처리
  Model/ProxyModel.swift 프록시 상태, 위젯 스냅샷 게시
  Views/                 메인, 설정, 온보딩, 연결 안내, Mac 안내
  Design/                토큰, 공용 컴포넌트 (SignalRing, StatusHero …)
  ProxyServer.swift      HTTP/CONNECT + SOCKS5 서버 (Network.framework)
  UdpRelay.swift         SOCKS5 UDP ASSOCIATE 릴레이
  KeepAlive.swift        무음 오디오 백그라운드 유지
Widget/                  잠금화면 / 홈 위젯
Shared/                  앱 ↔ 위젯 공유 스냅샷, 딥링크, 색상 에셋
mac/                     macOS sing-box TUN 자동화 스크립트
```

## 딥링크

| URL | 동작 |
|---|---|
| `hotspotproxy://open` | 앱 열기 |
| `hotspotproxy://start` / `stop` / `toggle` | 프록시 제어 |
| `hotspotproxy://copy` | 접속 주소 복사 |

단축어(Shortcuts) 앱의 "URL 열기"로 자동화할 수 있습니다.
