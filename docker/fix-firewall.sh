#!/bin/bash

keep_forwarding_clear() {
  iptables -w -L FORWARD | grep ciscovpn &>/dev/null
  FOUND=$?

  if [ $FOUND -eq 0 ]; then
    echo Flushing forwarding restrictions
    iptables -w -F FORWARD
    echo Setting up masquarade
    # Delete rule if it already exists (multiple times?)
    while iptables -w -t nat -D POSTROUTING -o cscotun0 -j MASQUERADE &>/dev/null; do true; done
    # Add rule
    iptables -w -t nat -A POSTROUTING -o cscotun0 -j MASQUERADE
  fi
}

while true; do
  keep_forwarding_clear
  sleep 1
done
