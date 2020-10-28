#!/bin/bash

# Script to download a .tar of release .apk's and sign them.  In order for this to work you need
# an android key store at ~/.loki-android.keystore (or alternatively set ANDROID_KEYSTORE), and
# you need the keystore and key passwords stored in the GNOME Keyring using:
#
#     secret-tool store --label='Loki Android keystore password' loki-android-keystore password
#     secret-tool store --label='Loki Android keystore - loki-wallet key password' loki-android-keystore-loki-wallet password
#
# These will prompt for the password. 'apt-get install libsecret-tools' if you don't have it already.
#
# You also need to `apt install apksigner` if you don't have that installed.

url=
path=
if [ "$#" -eq 1 ] && [[ "$1" =~ ^https://.*\.tar$ ]]; then
    url="$1"
elif [ "$#" -eq 1 ] && [ -d "$1" ]; then
    path="$1"
else
    echo "Usage: $0 https://builds.lokinet.dev/whatever/blah/android-wallet-123badcafe987-unsigned.tar"
    echo "or:    $0 path/containing/apks"
    exit 1
fi

if ! which apksigner >/dev/null; then
    echo "apksigner is not in your path; perhaps you need to apt-get it?"
    exit 1
fi

if ! which secret-tool >/dev/null; then
    echo "secret-tool is not in your path; perhaps you need to apt-get install libsecret-tools?"
    exit 1
fi

if ! secret-tool lookup loki-android-keystore password >/dev/null; then
    echo "Could not find keystore password via secret-tool."
    echo "To add it to your keychain run:"
    echo "    secret-tool store --label='Loki Android keystore password' loki-android-keystore password"
    echo "which will prompt for and securely store the password."
    exit 1
fi

if ! secret-tool lookup loki-android-keystore-loki-wallet password >/dev/null; then
    echo "Could not find keystore loki-wallet key password via secret-tool."
    echo "To add it to your keychain run:"
    echo "    secret-tool store --label='Loki Android keystore - loki-wallet key password' loki-android-keystore-loki-wallet password"
    echo "which will prompt for and securely store the password."
    exit 1
fi

set -o errexit


keystore=${ANDROID_KEYSTORE:-~/.loki-android.keystore}
if ! [ -f "$keystore" ]; then
    echo "Loki android keystore not found at $keystore: copy it there, or else set ANDROID_KEYSTORE"
    exit 1
fi

if [ -n "$url" ]; then
    path=${url/#*\//}
    path=${path%.tar}
    path=${path%-unsigned}
    if [ -z "$path" ]; then
        echo "Unexpected URL $url: couldn't figure out the expected extraction path"
        exit 1
    elif [ -d "$path" ]; then
        echo "$path already exists, refusing to download and extract into it"
        exit 1
    fi

    echo -e "\e[33;1mDownloading and extracting $url\e[0m"
    curl -sS "$url" | tar xv

    if ! [ -d "$path" ]; then
        echo "Files did not extract where I expected them to; I expected $path"
        exit 1
    fi

    echo -e "\e[32mExtracted apks to $path\e[0m"
fi

found=
for apk in "$path"/*.apk; do
    found=1
    echo -ne "\e[33;1mSigning $apk...\e[0m"
    apksigner sign --ks "$keystore" \
        --ks-pass file:<(secret-tool lookup loki-android-keystore password) \
        --key-pass file:<(secret-tool lookup loki-android-keystore-loki-wallet password) \
        --ks-key-alias loki-wallet \
        $apk
    echo -e "\e[32;1m Success!\e[0m"
done

if [ -z "$found" ]; then
    echo "Did not find any .apk's in the given path"
    exit 1
fi
