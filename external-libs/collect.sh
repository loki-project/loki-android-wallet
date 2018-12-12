#!/bin/bash

set -e

build_dir=/opt/android/build
if [ -z $1 ] ; then
    echo "Collecting libs from ${build_dir} directory!"
else
    build_dir=`pwd`/tmp_build
    rm -Rf $build_dir
    docker cp $1:/opt/android/build $build_dir
fi

orig_path=$PATH
packages=(boost openssl monero libsodium)

archs=(arm arm64 x86 x86_64)
#archs=(x86)

for arch in ${archs[@]}; do
    case ${arch} in
        "arm")
			xarch="armeabi-v7a"
			;;
        "arm64")
			xarch="arm64-v8a"
            ;;
        "x86")
			xarch="x86"
            ;;
        "x86_64")
			xarch="x86_64"
            ;;
        *)
			exit 16
            ;;
    esac

	for package in ${packages[@]}; do
    INPUT_DIR=`pwd`/build/build/$package
		OUTPUT_DIR=`pwd`/$package/lib/$xarch
		mkdir -p $OUTPUT_DIR
		rm -f $OUTPUT_DIR/*.a
		cp -a $build_dir/$package/$arch/lib/*.a $OUTPUT_DIR

		if [ $package = "monero" ]; then
            rm -rf $OUTPUT_DIR/../../include
            cp -a $build_dir/$package/include $OUTPUT_DIR/../..
		fi		

	done
done

if [[ ! -z $1 ]] ; then
    rm -rf $build_dir
fi

exit 0

