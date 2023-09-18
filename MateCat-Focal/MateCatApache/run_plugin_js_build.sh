cd "${MATECAT_HOME}" || exit 1

pushd plugins/aligner/app || exit
su -c "yarn install" "${USER}" || exit 1
su -c "yarn build:dev" "${USER}" || exit 1
node-prune
popd || exit