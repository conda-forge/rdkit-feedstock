#!/bin/bash

set -euxo pipefail

POPCNT_OPTIMIZATION="ON"
if [ "${target_platform}" == "linux-ppc64le" ] || [ "${target_platform}" == "linux-aarch64" ]; then
    # PowerPC includes -mcpu=power8 optimizations already
    # ARM does not have popcnt instructions, afaik
    POPCNT_OPTIMIZATION="OFF"
fi

# Resolve python and numpy include dirs explicitly so they're stable
# across native and cross-compile builds.
#
# Background: find_package(Python3 ... NumPy) records its include dirs into the
# exported RDKit::rdkit_py_base cmake target. For cross-compile (osx-arm64),
# running `python` resolves to the BUILD-env python and gives us BUILD-env
# paths under `_build_env/...`. Those paths don't get rewritten by conda-build's
# prefix relocation, so they end up in the installed rdkitpython-targets.cmake
# and break find_package(RDKit) for consumers on osx-arm64. See #114.
if [[ "${build_platform}" != "${target_platform}" ]]; then
    # Cross-compile: build directly from host PREFIX, don't run python.
    HOST_NUMPY_INCLUDE_DIR="${PREFIX}/lib/python${PY_VER}/site-packages/numpy/_core/include"
    if [ ! -d "${HOST_NUMPY_INCLUDE_DIR}" ]; then
        # numpy 1.x layout (pre-rename).
        HOST_NUMPY_INCLUDE_DIR="${PREFIX}/lib/python${PY_VER}/site-packages/numpy/core/include"
    fi
    if [ ! -d "${HOST_NUMPY_INCLUDE_DIR}" ]; then
        echo "ERROR: numpy include dir not found under ${PREFIX}/lib/python${PY_VER}/site-packages/numpy/{,_}core/include" >&2
        exit 1
    fi
    EXTRA_CMAKE_FLAGS=" -D Python3_NumPy_INCLUDE_DIR=${HOST_NUMPY_INCLUDE_DIR}"
    EXTRA_CMAKE_FLAGS="${EXTRA_CMAKE_FLAGS} -D Python3_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}"
else
    EXTRA_CMAKE_FLAGS=" -D Python3_NumPy_INCLUDE_DIR=$(python -c 'import numpy as np; print(np.get_include())')"
fi


PG_CONFIG="$(which pg_config)"
if [[ "${target_platform}" == "osx-arm64" || "${target_platform}" == "linux-ppc64le" || "${target_platform}" == "linux-aarch64" ]]; then
  # See https://github.com/conda-forge/pgvector-feedstock/blob/main/recipe/build.sh.
  chmod +x "${RECIPE_DIR}/arm64_pg_config"
  PG_CONFIG="${RECIPE_DIR}/arm64_pg_config"
fi

if [[ "${target_platform}" == "osx-64"  ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
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
