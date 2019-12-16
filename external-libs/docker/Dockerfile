FROM debian:jessie

RUN apt-get update && apt-get install -y unzip automake build-essential curl file pkg-config git python libtool
WORKDIR /opt/android

#Cmake
ARG CMAKE_VERSION=3.12.1
ARG CMAKE_VERSION_DOT=v3.12
ARG CMAKE_HASH=c53d5c2ce81d7a957ee83e3e635c8cda5dfe20c9d501a4828ee28e1615e57ab2
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
    && PATH=/opt/android/tool/arm/arm-linux-androideabi/bin:/opt/android/tool/arm/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-arm --prefix=/opt/android/build/boost/arm --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/arm64/aarch64-linux-android/bin:/opt/android/tool/arm64/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-arm64 --prefix=/opt/android/build/boost/arm64 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/x86/i686-linux-android/bin:/opt/android/tool/x86/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-x86 --prefix=/opt/android/build/boost/x86 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && PATH=/opt/android/tool/x86_64/x86_64-linux-android/bin:/opt/android/tool/x86_64/bin:$PATH ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --build-dir=android-x86_64 --prefix=/opt/android/build/boost/x86_64 --includedir=/opt/android/build/boost/include toolset=clang threading=multi threadapi=pthread target-os=android install \
    && ln -sf ../include /opt/android/build/boost/arm \
    && ln -sf ../include /opt/android/build/boost/arm64 \
    && ln -sf ../include /opt/android/build/boost/x86 \
    && ln -sf ../include /opt/android/build/boost/x86_64

# Sodium
ARG SODIUM_VERSION=1.0.16
ARG SODIUM_HASH=675149b9b8b66ff44152553fb3ebf9858128363d
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

# Building Loki from the latest commit on Android branch, this should be kept up to date with master
# with the necessary fixes by crtlib and m2049r to build for mobile.
RUN cd /opt/android \
    && git clone -b android https://github.com/loki-project/loki.git --recursive --depth=1 \
    && cd loki \
    && mkdir -p build/release \
    && ./build-all-arch.sh

# Uncomment this section to use loki from the docker directory if you want to
# easily build a custom version not depending on the specified branch above and
# comment out the section above that pulls from github.
# ADD loki /opt/android/loki
# RUN cd /opt/android/loki \
#      && rm -rf build \
#      && mkdir -p build/release \
#      && ./build-all-arch.sh
