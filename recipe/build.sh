#!/bin/bash

set -euxo pipefail

POPCNT_OPTIMIZATION="ON"
if [[ "$target_platform" == linux-ppc64le || "$target_platform" == linux-aarch64 ]]; then
    # PowerPC includes -mcpu=power8 optimizations already
    # ARM does not have popcnt instructions, afaik
    POPCNT_OPTIMIZATION="OFF"
fi

# Numpy cannot be found in ppc64le for some reason... some extra help will do ;)
EXTRA_CMAKE_FLAGS=""
if [[ "$target_platform" == linux-ppc64le ]]; then
    EXTRA_CMAKE_FLAGS+=" -D PYTHON_NUMPY_INCLUDE_PATH=${SP_DIR}/numpy/core/include"
fi

# workaround for clang++ and boost functional
if [[ "$target_platform" == osx-arm64 ]] || [[ "$target_platform" == osx-64 ]]; then
    export CXXFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY -D_HAS_AUTO_PTR_ETC=0 $CXXFLAGS"
fi

cmake ${CMAKE_ARGS} \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX="$PREFIX" \
    -D BOOST_ROOT="$PREFIX" \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D PYTHON_EXECUTABLE="$PYTHON" \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_CAIRO_SUPPORT=ON \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_FREESASA_SUPPORT=ON \
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON \
    -D RDK_BUILD_XYZ2MOL_SUPPORT=ON \
    -D RDK_BUILD_PYTHON_STUBS=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_OPTIMIZE_POPCNT=${POPCNT_OPTIMIZATION} \
    ${EXTRA_CMAKE_FLAGS} \
    .

make -j32  #$CPU_COUNT
make install

## How to run unit tests:
## 1. Set RDK_BUILD_CPP_TESTS to ON
## 2. Uncomment lines below
# export RDBASE="$SRC_DIR"
# ctest --output-on-failure

# NOTE(hadim): below we run `pip install ...` in order
# to correctly add the `.dist-info` directory in the package
# so python can correctly detect whether rdkit is installed
# when it's coming from a conda package.

# Set the version for setuptools_scm
echo "Settting SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION"
export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"

# Install the Python library
${PYTHON} -m pip install --no-deps --prefix ${PREFIX} .
