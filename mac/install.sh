#!/bin/bash
# 사용법: sudo bash install.sh   (한 번만)
set -euo pipefail
cd "$(dirname "$0")"
[ "$EUID" -eq 0 ] || { echo "sudo bash install.sh 로 실행하세요"; exit 1; }
mkdir -p /usr/local/etc/hotspot-tun /usr/local/var/hotspot-tun /usr/local/libexec
install -m 644 config.json /usr/local/etc/hotspot-tun/config.json
install -m 755 hotspot-tun.sh /usr/local/libexec/hotspot-tun.sh
install -m 644 com.indo.hotspot-tun.singbox.plist /Library/LaunchDaemons/
install -m 644 com.indo.hotspot-tun.watch.plist /Library/LaunchDaemons/
launchctl bootout system/com.indo.hotspot-tun.watch 2>/dev/null || true
launchctl bootout system/com.indo.hotspot-tun.singbox 2>/dev/null || true
launchctl bootstrap system /Library/LaunchDaemons/com.indo.hotspot-tun.watch.plist
sleep 3
launchctl print system/com.indo.hotspot-tun.singbox >/dev/null 2>&1 && echo "TUN 켜짐" || echo "대기 중 (핫스팟/프록시 앱 미연결 시 자동 꺼짐 상태)"
