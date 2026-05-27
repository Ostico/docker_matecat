# Vite dev server reverse proxy (included from VirtualHost)
# Toggle with: vite-proxy on|off|status
#
# When the Vite dev server is not running, Apache falls through to the
# local filesystem thanks to the health-check RewriteCond below.

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

# Only proxy when the Vite dev server is actually reachable
RewriteEngine On

# HMR WebSocket (only when Vite is up)
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteCond "127.0.0.1:5173" "-U" [OR]
RewriteCond %{REQUEST_URI} ^/__vite_hmr
RewriteRule ^/__vite_hmr(.*)$ "ws://127.0.0.1:5173/__vite_hmr$1" [P,L]

# Gate: check if Vite dev server is reachable before proxying
# If not, fall through to local filesystem / .htaccess rules
<Proxy "http://127.0.0.1:5173/*">
ProxySet timeout=120
ProxySet retry=5
</Proxy>

ProxyPass "/@vite" "http://127.0.0.1:5173/@vite" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/@vite" "http://127.0.0.1:5173/@vite"
ProxyPass "/@react-refresh" "http://127.0.0.1:5173/@react-refresh" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/@react-refresh" "http://127.0.0.1:5173/@react-refresh"
ProxyPass "/@fs/" "http://127.0.0.1:5173/@fs/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/@fs/" "http://127.0.0.1:5173/@fs/"
ProxyPass "/__vite_hmr" "ws://127.0.0.1:5173/__vite_hmr" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/__vite_hmr" "ws://127.0.0.1:5173/__vite_hmr"
ProxyPass "/vite-entries/" "http://127.0.0.1:5173/vite-entries/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/vite-entries/" "http://127.0.0.1:5173/vite-entries/"
ProxyPass "/node_modules/" "http://127.0.0.1:5173/node_modules/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/node_modules/" "http://127.0.0.1:5173/node_modules/"
ProxyPass "/public/" "http://127.0.0.1:5173/public/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/public/" "http://127.0.0.1:5173/public/"

# Plugins and Node Modules
ProxyPass "/plugins/" "http://127.0.0.1:5173/plugins/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/plugins/" "http://127.0.0.1:5173/plugins/"
ProxyPass "/node_modules/" "http://127.0.0.1:5173/node_modules/" retry=5 connectiontimeout=1 timeout=120
ProxyPassReverse "/node_modules/" "http://127.0.0.1:5173/node_modules/"

# Longer timeout for Vite (SCSS compilation can be slow on first load)
ProxyTimeout 120