# Vite dev server reverse proxy (included from VirtualHost)
# Toggle with: vite-proxy on|off|status
#
# Requests go to the Vite dev server on 127.0.0.1:5173. When it is not running,
# the balancer fails over to the hot standby on 127.0.0.1:8173 (vite-fallback.conf),
# which serves the same files statically, so the site keeps working on the last build.

# Disable caching for proxied paths
<LocationMatch "^/((@vite|@react-refresh|@fs|vite-entries|__vite_hmr|node_modules)(/|$))">
    ExpiresActive Off
    Header always unset Expires
    Header always set Cache-Control "no-store"
</LocationMatch>
<LocationMatch "^/public/">
    ExpiresActive Off
    Header always unset Expires
    Header always set Cache-Control "no-store"
</LocationMatch>

<Proxy "balancer://vite">
    BalancerMember "http://127.0.0.1:5173" retry=5 connectiontimeout=1 timeout=120
    BalancerMember "http://127.0.0.1:8173" status=+H
    ProxySet lbmethod=byrequests
</Proxy>

# HMR WebSocket: no fallback, the Vite client reconnects on its own
ProxyPass "/__vite_hmr" "http://127.0.0.1:5173/__vite_hmr" upgrade=websocket retry=0 connectiontimeout=1

ProxyPassMatch "^/(@react-refresh|(@vite|@fs|vite-entries|node_modules|public|plugins)/.*)$" "balancer://vite/$1"
ProxyPassReverse "/" "balancer://vite/"
