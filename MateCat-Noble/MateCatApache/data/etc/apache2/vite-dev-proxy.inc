# Vite dev server reverse proxy (included from VirtualHost)
# Toggle with: vite-proxy on|off|status

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

# HMR WebSocket
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/__vite_hmr(.*)$ "ws://127.0.0.1:5173/__vite_hmr$1" [P,L]

# Proxy Vite paths (before .htaccess static file serving)
ProxyPass "/__vite_hmr" "ws://127.0.0.1:5173/__vite_hmr"
ProxyPassReverse "/__vite_hmr" "ws://127.0.0.1:5173/__vite_hmr"
ProxyPass "/@vite" "http://127.0.0.1:5173/@vite"
ProxyPassReverse "/@vite" "http://127.0.0.1:5173/@vite"
ProxyPass "/@react-refresh" "http://127.0.0.1:5173/@react-refresh"
ProxyPassReverse "/@react-refresh" "http://127.0.0.1:5173/@react-refresh"
ProxyPass "/@fs/" "http://127.0.0.1:5173/@fs/"
ProxyPassReverse "/@fs/" "http://127.0.0.1:5173/@fs/"
ProxyPass "/vite-entries/" "http://127.0.0.1:5173/vite-entries/"
ProxyPassReverse "/vite-entries/" "http://127.0.0.1:5173/vite-entries/"
ProxyPass "/public/" "http://127.0.0.1:5173/public/"
ProxyPassReverse "/public/" "http://127.0.0.1:5173/public/"
ProxyPass "/plugins/" "http://127.0.0.1:5173/plugins/"
ProxyPassReverse "/plugins/" "http://127.0.0.1:5173/plugins/"
ProxyPass "/node_modules/" "http://127.0.0.1:5173/node_modules/"
ProxyPassReverse "/node_modules/" "http://127.0.0.1:5173/node_modules/"

SetEnv VITE_DEV 1

# Longer timeout for Vite (SCSS compilation can be slow on first load)
<Proxy "http://127.0.0.1:5173/*">
    ProxySet timeout=120
</Proxy>
