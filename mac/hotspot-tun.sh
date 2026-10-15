#!/bin/bash
# Runs on network changes (and every 30s). Turns the TUN on when on the iPhone hotspot with the proxy app up, off otherwise.
LABEL=com.indo.hotspot-tun.singbox
PLIST=/Library/LaunchDaemons/$LABEL.plist
SVC=Wi-Fi
TUN_DNS=172.19.0.2   # address inside the TUN; sing-box hijacks it and resolves via the proxy
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
# When hotspot mode flips, restart tailscaled so it picks up the right proxy env
MODE_FILE=/usr/local/var/hotspot-tun/mode
if on_hotspot && proxy_up; then MODE=hotspot; else MODE=normal; fi
if [ "$(cat $MODE_FILE 2>/dev/null)" != "$MODE" ]; then
  echo "$MODE" > $MODE_FILE
  /bin/launchctl print system/com.indo.tailscaled >/dev/null 2>&1 && /bin/launchctl kickstart -k system/com.indo.tailscaled
fi
exit 0
