#!/bin/bash

set -euxo pipefail

if [ "${PKG_NAME}" == "librdkit" ]; then

    # NOTE(skearnes): List is from `make list_install_components`, excluding "python" and "pgsql".
    for COMPONENT in Unspecified base data dev docs extras runtime; do
      cmake -D CMAKE_INSTALL_COMPONENT="${COMPONENT}" -P cmake_install.cmake
    done

elif [ "${PKG_NAME}" == "rdkit" ]; then

    cmake -D CMAKE_INSTALL_COMPONENT=python -P cmake_install.cmake
    cmake --build . --config Release --target stubs

    # NOTE(hadim): Below we run `pip install ...` in order to correctly add the `.dist-info` directory in the package
    # so python can correctly detect whether rdkit is installed when it's coming from a conda package.

    # Set the version for setuptools_scm.
    export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

    # Install the Python library.
    ${PYTHON} -m pip install --no-deps -vv --no-build-isolation --prefix "${PREFIX}" .

elif [ "${PKG_NAME}" == "rdkit-postgresql" ]; then

    if [ "${target_platform}" == "osx-arm64" ] || [ "${target_platform}" == "osx-64" ]; then
      # NOTE(skearnes): PostgreSQL doesn't recognize `rdkit.so` on OSX.
      DIR="$(pg_config --pkglibdir)"
      ln -s "${DIR}"/rdkit.so "${DIR}"/rdkit
    fi
    cd ./Code/PgSQL/rdkit
    cmake -P cmake_install.cmake

fi
