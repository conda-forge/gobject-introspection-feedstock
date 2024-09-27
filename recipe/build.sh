#!/bin/bash

set -ex

if [[ "$target_platform" == osx-* ]] ; then
    # dead_strip_dylibs breaks some tests
    LDFLAGS=${LDFLAGS//-Wl,-dead_strip_dylibs/}
fi

mkdir -p $PREFIX/libexec
cp $RECIPE_DIR/load.sh $PREFIX/libexec/gi-cross-launcher-load.sh
cp $RECIPE_DIR/save.sh $PREFIX/libexec/gi-cross-launcher-save.sh

export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p build-host
    pushd build-host

    export CC=$CC_FOR_BUILD
    export AR="$($CC_FOR_BUILD -print-prog-name=ar)"
    export NM="$($CC_FOR_BUILD -print-prog-name=nm)"
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS

    $BUILD_PREFIX/bin/python3 $(which meson) --prefix="$BUILD_PREFIX" --backend=ninja -Dlibdir=lib \
          -Dcairo=enabled -Dpython="$BUILD_PREFIX/bin/python3" ..

    # This script would generate the functions.txt and dump.xml and save them
    # This is loaded in the native build. We assume that the functions exported
    # by glib are the same for the native and cross builds
    export GI_CROSS_LAUNCHER=$PREFIX/libexec/gi-cross-launcher-save.sh
    ninja -j${CPU_COUNT}
    ninja install

    popd
  )
  export GI_CROSS_LAUNCHER=$PREFIX/libexec/gi-cross-launcher-load.sh
  MESON_ARGS="-Dgi_cross_use_prebuilt_gi=True ${MESON_ARGS}"
fi

mkdir forgebuild
cd forgebuild
meson ${MESON_ARGS} \
    --prefix="$PREFIX" \
    --backend=ninja \
    -Dlibdir=lib \
    -Dcairo=enabled \
    -Dpython="$PYTHON" \
    ..
ninja -v
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 ]]; then
  ninja test
fi
ninja install

rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
