#!/bin/bash
# tailscaled는 물리 인터페이스(en0)에 직접 바인딩해서 TUN을 우회한다.
# 그래서 핫스팟일 때만 폰 프록시를 환경변수로 넘겨 컨트롤/DERP(HTTPS)를 프록시로 보낸다.
if /sbin/ifconfig | grep -q "inet 172\.20\.10\." && /usr/bin/nc -z -G 2 172.20.10.1 8080 >/dev/null 2>&1; then
  export HTTPS_PROXY=http://172.20.10.1:8080 HTTP_PROXY=http://172.20.10.1:8080
fi
exec /opt/homebrew/bin/tailscaled
