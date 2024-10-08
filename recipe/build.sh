#!/bin/bash

set -euxo pipefail

POPCNT_OPTIMIZATION="ON"
if [ "${target_platform}" == "linux-ppc64le" ] || [ "${target_platform}" == "linux-aarch64" ]; then
    # PowerPC includes -mcpu=power8 optimizations already
    # ARM does not have popcnt instructions, afaik
    POPCNT_OPTIMIZATION="OFF"
fi

EXTRA_CMAKE_FLAGS=" -D Python3_NumPy_INCLUDE_DIR=$(python -c 'import numpy as np; print(np.get_include())')"


PG_CONFIG="$(which pg_config)"
if [[ "${target_platform}" == "osx-arm64" || "${target_platform}" == "linux-ppc64le" || "${target_platform}" == "linux-aarch64" ]]; then
  # See https://github.com/conda-forge/pgvector-feedstock/blob/main/recipe/build.sh.
  chmod +x "${RECIPE_DIR}/arm64_pg_config"
  PG_CONFIG="${RECIPE_DIR}/arm64_pg_config"
fi
time cmake ${CMAKE_ARGS} \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D BOOST_ROOT="${PREFIX}" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D PostgreSQL_CONFIG="${PG_CONFIG}" \
    -D Python3_EXECUTABLE="${PYTHON}" \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_CAIRO_SUPPORT=ON \
    -D RDK_BUILD_CONTRIB=ON \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_FREESASA_SUPPORT=ON \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_PGSQL=ON \
    -D RDK_BUILD_XYZ2MOL_SUPPORT=ON \
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_OPTIMIZE_POPCNT="${POPCNT_OPTIMIZATION}" \
    -D RDK_PGSQL_STATIC=OFF \
    ${EXTRA_CMAKE_FLAGS} \
    .

time make -j"${CPU_COUNT}"

## How to run unit tests:
## 1. Set RDK_BUILD_CPP_TESTS to ON
## 2. Uncomment lines below
# export RDBASE="$SRC_DIR"
# ctest --output-on-failure
