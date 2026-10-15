#!/bin/bash
# tailscaled binds directly to the physical interface (en0), bypassing the TUN,
# so on the hotspot we pass the phone proxy via env to route control/DERP (HTTPS) through it.
if /sbin/ifconfig | grep -q "inet 172\.20\.10\." && /usr/bin/nc -z -G 2 172.20.10.1 8080 >/dev/null 2>&1; then
  export HTTPS_PROXY=http://172.20.10.1:8080 HTTP_PROXY=http://172.20.10.1:8080
fi
exec /opt/homebrew/bin/tailscaled
