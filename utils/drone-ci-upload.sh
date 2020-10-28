#!/usr/bin/env bash

# Script used with Drone CI to upload build artifacts (because specifying all this in
# .drone.jsonnet is too painful).



set -o errexit

if [ -z "$SSH_KEY" ]; then
    echo -e "\n\n\n\e[31;1mUnable to upload artifact: SSH_KEY not set\e[0m"
    # Just warn but don't fail, so that this doesn't trigger a build failure for untrusted builds
    exit 0
fi

echo "$SSH_KEY" >ssh_key

set -o xtrace  # Don't start tracing until *after* we write the ssh key

chmod 600 ssh_key

branch_or_tag=${DRONE_BRANCH:-${DRONE_TAG:-unknown}}

upload_to="builds.lokinet.dev/${DRONE_REPO// /_}/${branch_or_tag// /_}"

# sftp doesn't have any equivalent to mkdir -p, so we have to split the above up into a chain of
# -mkdir a/, -mkdir a/b/, -mkdir a/b/c/, ... commands.  The leading `-` allows the command to fail
# without error.
upload_dirs=(${upload_to//\// })
uploadcmds=
dir_tmp=""
for p in "${upload_dirs[@]}"; do
    dir_tmp="$dir_tmp$p/"
    uploadcmds="$uploadcmds
-mkdir $dir_tmp"
done

for apk in app/build/outputs/apk/prodMainnet/release/loki-wallet-*.apk app/build/outputs/apk/prodStagenet/release/loki-wallet-*-testnet_*.apk; do
    uploadcmds="$uploadcmds
put $apk $upload_to"
done

sftp -i ssh_key -b - -o StrictHostKeyChecking=off drone@builds.lokinet.dev <<SFTP
$uploadcmds
SFTP

set +o xtrace

echo -e "\n\n\n\n\e[32;1mUploaded to https://${upload_to}/\e[0m\n\n\n"

