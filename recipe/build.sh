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

# this can be removed when 2022.09.2 is released
cat << EOF > patch.txt
diff --git a/Code/RDGeneral/CMakeLists.txt b/Code/RDGeneral/CMakeLists.txt
index 5915fabad..c71e15465 100644
--- a/Code/RDGeneral/CMakeLists.txt
+++ b/Code/RDGeneral/CMakeLists.txt
@@ -79,9 +79,11 @@ if(RDK_BUILD_THREADSAFE_SSS)
 rdkit_test(testConcurrentQueue testConcurrentQueue.cpp LINK_LIBRARIES RDGeneral)
 endif(RDK_BUILD_THREADSAFE_SSS)
 
+if(RDK_BUILD_CPP_TESTS)
 add_library(rdkitCatch catch_main.cpp)
 target_link_libraries(rdkitCatch PUBLIC rdkit_base)
 target_include_directories(rdkitCatch PUBLIC ${CATCH_INCLUDE_DIR})
+endif(RDK_BUILD_CPP_TESTS)
 
 
 rdkit_catch_test(dictTestsCatch catch_dict.cpp 
EOF

patch -p1 < patch.txt

cmake ${CMAKE_ARGS} \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX="$PREFIX" \
    -D BOOST_ROOT="$PREFIX" \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D PYTHON_EXECUTABLE="$PYTHON" \
    -D PYTHON_INSTDIR="$SP_DIR" \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_CAIRO_SUPPORT=ON \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_FREESASA_SUPPORT=ON \
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON \
    -D RDK_BUILD_XYZ2MOL_SUPPORT=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_OPTIMIZE_POPCNT=${POPCNT_OPTIMIZATION} \
    ${EXTRA_CMAKE_FLAGS} \
    .

make -j$CPU_COUNT
make install

## How to run unit tests:
## 1. Set RDK_BUILD_CPP_TESTS to ON
## 2. Uncomment lines below
# export RDBASE="$SRC_DIR"
# ctest --output-on-failure
