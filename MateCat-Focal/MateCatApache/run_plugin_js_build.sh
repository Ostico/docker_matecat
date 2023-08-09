cd "${MATECAT_HOME}" || exit 1

pushd plugins || exit 1
for i in ./*; do

    pushd "${i}" || exit 1;
    chown -R "${USER_OWNER}" .

    if [ "$i" = "translated" ]; then
        echo "Skip JS build for $i plugin.";
        popd || exit 1;
        continue;
    fi

    su -c "yarn install" "${USER_OWNER}"
    su -c "grunt" "${USER_OWNER}"

    popd || exit 1;

done
popd || exit 1