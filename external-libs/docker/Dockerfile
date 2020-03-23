FROM debian:jessie

RUN set -ex && \
    apt-get update && \
    apt-get install -y eatmydata && \
    eatmydata apt-get --no-install-recommends --yes install \
        ca-certificates \
        apt-transport-https \
        curl \
        unzip \
        automake \
        python \
        build-essential \
        file \
        pkg-config \
        libssl-dev \
        libtool-bin \
        git

WORKDIR /opt/android

#Cmake
ARG CMAKE_VERSION=3.16.5
ARG CMAKE_VERSION_DOT=v3.16
ARG CMAKE_HASH=5f760b50b8ecc9c0c37135fae5fbf00a2fef617059aa9d61c1bb91653e5a8bfc
RUN set -ex \
    && curl -s -O https://cmake.org/files/${CMAKE_VERSION_DOT}/cmake-${CMAKE_VERSION}.tar.gz \
    && echo "${CMAKE_HASH}  cmake-${CMAKE_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./configure \
    && make \
    && make install

ENV ANDROID_NDK_REVISION 17b
ENV BOOST_VERSION 1_67_0
ENV BOOST_VERSION_DOT 1.67.0

## Getting Android NDK
RUN curl -s -O https://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip \
    && unzip android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip \
    && rm -f android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip \
    && ln -s android-ndk-r${ANDROID_NDK_REVISION} ndk

## Installing toolchains
RUN ndk/build/tools/make_standalone_toolchain.py --api 21 --stl=libc++ --arch arm --install-dir /opt/android/tool/arm \
    && ndk/build/tools/make_standalone_toolchain.py --api 21 --stl=libc++ --arch arm64 --install-dir /opt/android/tool/arm64 \
    && ndk/build/tools/make_standalone_toolchain.py --api 21 --stl=libc++ --arch x86 --install-dir /opt/android/tool/x86 \
    && ndk/build/tools/make_standalone_toolchain.py --api 21 --stl=libc++ --arch x86_64 --install-dir /opt/android/tool/x86_64

## Building OpenSSL
RUN git clone https://github.com/m2049r/android-openssl.git --depth=1 \
    && curl -L -s -O https://github.com/openssl/openssl/archive/OpenSSL_1_0_2l.tar.gz \
    && cd android-openssl \
    && tar xfz ../OpenSSL_1_0_2l.tar.gz \
    && rm -f ../OpenSSL_1_0_2l.tar.gz \
    && ANDROID_NDK_ROOT=/opt/android/ndk ./build-all-arch.sh

RUN [ "/bin/bash", "-c", "mkdir -p /opt/android/build/openssl/{arm,arm64,x86,x86_64} \
    && cp -a /opt/android/android-openssl/prebuilt/armeabi /opt/android/build/openssl/arm/lib \
    && cp -a /opt/android/android-openssl/prebuilt/arm64-v8a /opt/android/build/openssl/arm64/lib \
    && cp -a /opt/android/android-openssl/prebuilt/x86 /opt/android/build/openssl/x86/lib \
    && cp -a /opt/android/android-openssl/prebuilt/x86_64 /opt/android/build/openssl/x86_64/lib \
    && cp -aL /opt/android/android-openssl/openssl-OpenSSL_1_0_2l/include/openssl/ /opt/android/build/openssl/include \
    && ln -s /opt/android/build/openssl/include /opt/android/build/openssl/arm/include \
    && ln -s /opt/android/build/openssl/include /opt/android/build/openssl/arm64/include \
    && ln -s /opt/android/build/openssl/include /opt/android/build/openssl/x86/include \
    && ln -s /opt/android/build/openssl/include /opt/android/build/openssl/x86_64/include \
    && ln -sf /opt/android/build/openssl/include /opt/android/tool/arm/sysroot/usr/include/openssl \
    && ln -sf /opt/android/build/openssl/arm/lib/*.so /opt/android/tool/arm/sysroot/usr/lib \
    && ln -sf /opt/android/build/openssl/include /opt/android/tool/arm64/sysroot/usr/include/openssl \
    && ln -sf /opt/android/build/openssl/arm64/lib/*.so /opt/android/tool/arm64/sysroot/usr/lib \
    && ln -sf /opt/android/build/openssl/include /opt/android/tool/x86/sysroot/usr/include/openssl \
    && ln -sf /opt/android/build/openssl/x86/lib/*.so /opt/android/tool/x86/sysroot/usr/lib \
    && ln -sf /opt/android/build/openssl/include /opt/android/tool/x86_64/sysroot/usr/include/openssl \
    && ln -sf /opt/android/build/openssl/x86_64/lib/*.so /opt/android/tool/x86_64/sysroot/usr/lib64" ]

## Building Boost
RUN cd /opt/android \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2/download \
    && tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
    && rm -f /usr/boost_${BOOST_VERSION}.tar.bz2 \
    && cd boost_${BOOST_VERSION} \
    && ./bootstrap.sh

## Building Boost
RUN cd boost_${BOOST_VERSION} \
    && PATH=/opt/android/tool/arm/arm-linux-androideabi/bin:/opt/android/tool/arm/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-atomic --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-arm --prefix=/opt/android/build/boost/arm --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/arm64/aarch64-linux-android/bin:/opt/android/tool/arm64/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-atomic --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-arm64 --prefix=/opt/android/build/boost/arm64 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/x86/i686-linux-android/bin:/opt/android/tool/x86/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-atomic --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-x86 --prefix=/opt/android/build/boost/x86 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/x86_64/x86_64-linux-android/bin:/opt/android/tool/x86_64/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-atomic --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-x86_64 --prefix=/opt/android/build/boost/x86_64 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && ln -sf ../include /opt/android/build/boost/arm \
    && ln -sf ../include /opt/android/build/boost/arm64 \
    && ln -sf ../include /opt/android/build/boost/x86 \
    && ln -sf ../include /opt/android/build/boost/x86_64

# Sodium
ARG SODIUM_VERSION=1.0.18-RELEASE
ARG SODIUM_HASH=940ef42797baa0278df6b7fd9e67c7590f87744b
RUN set -ex \
    && cd /opt/android \
    && git clone https://github.com/jedisct1/libsodium.git -b ${SODIUM_VERSION} --depth=1 \
    && cd libsodium \
    && test `git rev-parse HEAD` = ${SODIUM_HASH} || exit 1 \
    && ./autogen.sh

## Building Sodium
RUN cd /opt/android/libsodium \
    && PATH=/opt/android/tool/arm/arm-linux-androideabi/bin:/opt/android/tool/arm/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libsodium/arm --host=arm-linux-androideabi --enable-static --disable-shared && make && make install && make clean \
    && PATH=/opt/android/tool/arm64/aarch64-linux-android/bin:/opt/android/tool/arm64/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libsodium/arm64 --host=aarch64-linux-android --enable-static --disable-shared && make && make install && make clean \
    && PATH=/opt/android/tool/x86/i686-linux-android/bin:/opt/android/tool/x86/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libsodium/x86 --host=i686-linux-android --enable-static --disable-shared && make && make install && make clean \
    && PATH=/opt/android/tool/x86_64/x86_64-linux-android/bin:/opt/android/tool/x86_64/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libsodium/x86_64 --host=x86_64-linux-android --enable-static --disable-shared && make && make install && make clean

# Sqlite3
ARG SQLITE_VERSION=3310100
ARG SQLITE_HASH=62284efebc05a76f909c580ffa5c008a7d22a1287285d68b7825a2b6b51949ae
RUN set -ex \
    && cd /opt/android \
    && curl -s -O https://sqlite.org/2020/sqlite-autoconf-${SQLITE_VERSION}.tar.gz \
    && echo "${SQLITE_HASH}  sqlite-autoconf-${SQLITE_VERSION}.tar.gz" | sha256sum -c \
    && tar xf sqlite-autoconf-${SQLITE_VERSION}.tar.gz \
    && mv sqlite-autoconf-${SQLITE_VERSION} sqlite

## Building Sodium
RUN cd /opt/android/sqlite \
    && PATH=/opt/android/tool/arm/arm-linux-androideabi/bin:/opt/android/tool/arm/bin:$PATH ; CC=clang CXX=clang++ ./configure --prefix=/opt/android/build/sqlite/arm --host=arm-linux-androideabi --disable-shared --with-pic && make && make install && make clean \
    && PATH=/opt/android/tool/arm64/aarch64-linux-android/bin:/opt/android/tool/arm64/bin:$PATH ; CC=clang CXX=clang++ ./configure --prefix=/opt/android/build/sqlite/arm64 --host=aarch64-linux-android --disable-shared --with-pic && make && make install && make clean \
    && PATH=/opt/android/tool/x86/i686-linux-android/bin:/opt/android/tool/x86/bin:$PATH ; CC=clang CXX=clang++ ./configure --prefix=/opt/android/build/sqlite/x86 --host=i686-linux-android --disable-shared --with-pic && make && make install && make clean \
    && PATH=/opt/android/tool/x86_64/x86_64-linux-android/bin:/opt/android/tool/x86_64/bin:$PATH ; CC=clang CXX=clang++ ./configure --prefix=/opt/android/build/sqlite/x86_64 --host=x86_64-linux-android --disable-shared --with-pic && make && make install && make clean

# ZMQ
ARG ZMQ_VERSION=v4.3.2
ARG ZMQ_HASH=a84ffa12b2eb3569ced199660bac5ad128bff1f0
RUN set -ex \
    && cd /opt/android \
    && git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} --depth=1 \
    && cd libzmq \
    && test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
    && ./autogen.sh

## Building ZMQ
RUN cd /opt/android/libzmq \
    && PATH=/opt/android/tool/arm/arm-linux-androideabi/bin:/opt/android/tool/arm/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libzmq/arm --host=arm-linux-androideabi --enable-static --disable-shared && make && make install && ldconfig && make clean \
    && PATH=/opt/android/tool/arm64/aarch64-linux-android/bin:/opt/android/tool/arm64/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libzmq/arm64 --host=aarch64-linux-android --enable-static --disable-shared && make && make install && ldconfig && make clean \
    && PATH=/opt/android/tool/x86/i686-linux-android/bin:/opt/android/tool/x86/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libzmq/x86 --host=i686-linux-android --enable-static --disable-shared && make && make install && ldconfig && make clean \
    && PATH=/opt/android/tool/x86_64/x86_64-linux-android/bin:/opt/android/tool/x86_64/bin:$PATH ; CC=clang CXX=clang++ CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --prefix=/opt/android/build/libzmq/x86_64 --host=x86_64-linux-android --enable-static --disable-shared && make && make install && ldconfig && make clean

# Building Loki from the latest commit on Android branch, this should be kept up to date with master
# with the necessary fixes by crtlib and m2049r to build for mobile.
# RUN cd /opt/android \
#     && git clone -b android https://github.com/loki-project/loki.git --recursive --depth=1 \
#     && cd loki \
#     && mkdir -p build/release \
#     && ./build-all-arch.sh

# Uncomment this section to use loki from the docker directory if you want to
# easily build a custom version not depending on the specified branch above and
# comment out the section above that pulls from github.
ADD loki /opt/android/loki
RUN cd /opt/android/loki \
     && rm -rf build \
     && mkdir -p build/release \
     && ./build-all-arch.sh
