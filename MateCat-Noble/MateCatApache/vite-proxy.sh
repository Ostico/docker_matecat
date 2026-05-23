#!/bin/bash
# Toggle Vite dev server reverse proxy in Apache
# Usage: vite-proxy {on|off|status}

CONF="/etc/apache2/sites-enabled/443-matecat.conf"
ENABLED="IncludeOptional /etc/apache2/vite-dev-proxy.inc"
DISABLED="#IncludeOptional /etc/apache2/vite-dev-proxy.inc"

case "$1" in
  on)
    sed -i "s|${DISABLED}|${ENABLED}|" "$CONF" && apachectl graceful
    echo "Vite dev proxy enabled. Run 'yarn watch' to start Vite."
    ;;
  off)
    sed -i "s|${ENABLED}|${DISABLED}|" "$CONF" && apachectl graceful
    echo "Vite dev proxy disabled. Apache serves static builds."
    ;;
  status)
    if grep -q "^[[:space:]]*IncludeOptional.*/vite-dev-proxy.inc" "$CONF"; then
      echo "ON"
    else
      echo "OFF"
    fi
    ;;
  *)
    echo "Usage: vite-proxy {on|off|status}"
    exit 1
    ;;
esac
