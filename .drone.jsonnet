local apt_get_quiet = 'apt-get -o=Dpkg::Use-Pty=0 -q';

// Download URL for bundled android deps build from loki-core:
local loki_deps_url = 'https://builds.lokinet.dev/jagerman/loki/android-build/android-deps-73c98416a95a91db2c068e8eb39444cc059e652f.tar.xz';

[
    {   name: 'Android build', kind: 'pipeline', type: 'docker', platform: { arch: 'amd64' },
        steps: [
            {
                name: 'Build',
                image: 'debian:sid',
                environment: { SSH_KEY: { from_secret: "SSH_KEY" } },
                commands: [
                    'echo "man-db man-db/auto-update boolean false" | debconf-set-selections',
                    apt_get_quiet + ' update',
                    apt_get_quiet + ' install -y eatmydata',
                    'eatmydata ' + apt_get_quiet + ' dist-upgrade -y',
                    'eatmydata ' + apt_get_quiet + ' install -y --no-install-recommends default-jre-headless curl ca-certificates tar xz-utils unzip git',
                    'git fetch --tags',
                    'curl -L ' + loki_deps_url + ' | tar --transform="s#^android-deps-[^/]*#loki-core-deps#" -xvJ',
                    'curl https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip --output clitools.zip',
                    'unzip clitools.zip -d /sdk',
                    'export ANDROID_SDK_ROOT=/sdk PATH="/sdk/cmdline-tools/bin:$PATH"',
                    'yes | sdkmanager --sdk_root=/sdk --licenses',
                    './gradlew assembleRelease',
                    './utils/drone-ci-upload.sh'
                    ]
            },
        ]
    }
]
