#!/bin/bash
# 사용법: sudo ~/code/project/hotspot-proxy/mac/install-tailscale.sh  (한 번만)
# GUI Tailscale 앱 대신 CLI tailscaled를 자동 시작 서비스로 등록한다.
set -euo pipefail
cd "$(dirname "$0")"
[ "$EUID" -eq 0 ] || { echo "sudo 로 실행하세요"; exit 1; }
osascript -e 'quit app "Tailscale"' 2>/dev/null || true
pkill -x Tailscale 2>/dev/null || true
pkill -x tailscaled 2>/dev/null || true
sleep 2
install -m 755 tailscaled-wrapper.sh /usr/local/libexec/tailscaled-wrapper.sh
install -m 755 hotspot-tun.sh /usr/local/libexec/hotspot-tun.sh
install -m 644 com.indo.tailscaled.plist /Library/LaunchDaemons/
launchctl bootout system/com.indo.tailscaled 2>/dev/null || true
launchctl bootstrap system /Library/LaunchDaemons/com.indo.tailscaled.plist
sleep 5
/opt/homebrew/bin/tailscale up 2>&1 | tail -2 || true
/opt/homebrew/bin/tailscale status | head -3
