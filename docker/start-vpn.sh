if [ -f /response.txt ]; then
  cat /response.txt | envsubst '$VPN_PASSWORD' | /opt/cisco/anyconnect/bin/vpn -s && \
  unset VPN_PASSWORD && \
  tail -f /dev/null
else
  /opt/cisco/anyconnect/bin/vpn
fi