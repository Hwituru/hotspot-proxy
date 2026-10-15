#!/bin/bash
# 네트워크가 바뀔 때(+30초마다) 호출됨. 아이폰 핫스팟 + 프록시 앱이 살아 있으면 TUN 켜고, 아니면 끈다.
LABEL=com.indo.hotspot-tun.singbox
PLIST=/Library/LaunchDaemons/$LABEL.plist
SVC=Wi-Fi
TUN_DNS=172.19.0.2   # TUN 안쪽 주소 -> sing-box가 가로채서 프록시로 해석
on_hotspot() { /sbin/ifconfig | grep -q "inet 172\.20\.10\."; }
proxy_up() { /usr/bin/nc -z -G 2 172.20.10.1 8080 >/dev/null 2>&1; }
running() { /bin/launchctl print system/$LABEL >/dev/null 2>&1; }
dns_is() { /usr/sbin/networksetup -getdnsservers "$SVC" | grep -qx "$1"; }
if on_hotspot && proxy_up; then
  running || /bin/launchctl bootstrap system "$PLIST"
  dns_is "$TUN_DNS" || /usr/sbin/networksetup -setdnsservers "$SVC" "$TUN_DNS"
else
  running && /bin/launchctl bootout system/$LABEL
  dns_is "$TUN_DNS" && /usr/sbin/networksetup -setdnsservers "$SVC" Empty
fi
# 핫스팟 여부가 바뀌면 tailscaled를 재시작해 프록시 환경변수를 다시 정함
MODE_FILE=/usr/local/var/hotspot-tun/mode
if on_hotspot && proxy_up; then MODE=hotspot; else MODE=normal; fi
if [ "$(cat $MODE_FILE 2>/dev/null)" != "$MODE" ]; then
  echo "$MODE" > $MODE_FILE
  /bin/launchctl print system/com.indo.tailscaled >/dev/null 2>&1 && /bin/launchctl kickstart -k system/com.indo.tailscaled
fi
exit 0
