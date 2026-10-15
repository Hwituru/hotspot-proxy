#!/bin/bash
# Usage: sudo bash uninstall.sh
launchctl bootout system/com.indo.hotspot-tun.watch 2>/dev/null
launchctl bootout system/com.indo.hotspot-tun.singbox 2>/dev/null
/usr/sbin/networksetup -getdnsservers Wi-Fi | grep -qx 172.19.0.2 && /usr/sbin/networksetup -setdnsservers Wi-Fi Empty
launchctl bootout system/com.indo.tailscaled 2>/dev/null
rm -f /Library/LaunchDaemons/com.indo.tailscaled.plist /usr/local/libexec/tailscaled-wrapper.sh
rm -f /Library/LaunchDaemons/com.indo.hotspot-tun.*.plist /usr/local/libexec/hotspot-tun.sh
rm -rf /usr/local/etc/hotspot-tun /usr/local/var/hotspot-tun
echo "Uninstalled"
