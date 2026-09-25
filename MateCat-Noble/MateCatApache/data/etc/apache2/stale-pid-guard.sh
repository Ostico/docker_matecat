# Drop a pid file left behind by a killed Apache when its PID now belongs to another process.
# Sourced from envvars, so it runs before every init script and apache2ctl command.
#
# Needed only when the Apache master dies without cleaning up, on kill -9 or an OOM kill, inside a
# running container. The init script then sees the recycled PID alive and `service apache2 start`
# returns 0 without starting anything. Container boot is already covered by the rm in run.sh.
if [ -f "$APACHE_PID_FILE" ]; then
    _stale_pid=$(cat "$APACHE_PID_FILE" 2>/dev/null)
    _stale_exe=$(readlink "/proc/${_stale_pid:-0}/exe" 2>/dev/null)
    if [ -n "$_stale_exe" ] && [ "${_stale_exe##*/}" != "apache2" ]; then
        rm -f "$APACHE_PID_FILE"
    fi
    unset _stale_pid _stale_exe
fi
