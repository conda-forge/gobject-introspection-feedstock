#! /bin/bash

set -e

set -x

declare -a configure_args

configure_args+=(--prefix=${PREFIX})
configure_args+=(--host=${HOST})
configure_args+=(--disable-dependency-tracking)
configure_args+=(--with-cairo)
# TODO :: Remove the True here, it is working around a conda-build bug.
if [[ ${PY3K} == True ]] || [[ ${PY3K} == 1 ]]; then
  configure_args+=(--with-python=${PYTHON}3)
else
  configure_args+=(--with-python=${PYTHON})
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

if [ -z "$OSX_ARCH" ] ; then
    echo "Skipping make check on linux due to libtool cross bug"
    # make check
else
    # Test suite does not fully work on OSX, but not because anything is broken.
    make check-local check-TESTS
    (cd tests && make check-TESTS) || exit 1
    (cd tests/offsets && make check) || exit 1
    (cd tests/warn && make check) || exit 1
fi

rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la

sed -i.bak 's|g_ir_scanner=${bindir}/g-ir-scanner|g_ir_scanner=python ${bindir}/g-ir-scanner|g' "${PREFIX}"/lib/pkgconfig/gobject-introspection-1.0.pc
sed -i.bak 's|g_ir_scanner=${bindir}/g-ir-scanner|g_ir_scanner=python ${bindir}/g-ir-scanner|g' "${PREFIX}"/lib/pkgconfig/gobject-introspection-no-export-1.0.pc
# diff -urN "${PREFIX}"/lib/pkgconfig/gobject-introspection-1.0.pc.bak "${PREFIX}"/lib/pkgconfig/gobject-introspection-1.0.pc
# diff -urN "${PREFIX}"/lib/pkgconfig/gobject-introspection-no-export-1.0.pc.bak "${PREFIX}"/lib/pkgconfig/gobject-introspection-no-export-1.0.pc
rm "${PREFIX}"/lib/pkgconfig/gobject-introspection-1.0.pc.bak "${PREFIX}"/lib/pkgconfig/gobject-introspection-no-export-1.0.pc.bak
