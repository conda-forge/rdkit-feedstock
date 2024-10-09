#!/bin/bash

set -euxo pipefail

if [ "${PKG_NAME}" == "librdkit" ]; then

    # NOTE(skearnes): List is from `make list_install_components`,
    # excluding "dev", "docs", "extras", "python", and "pgsql".
    for COMPONENT in Unspecified base data runtime; do
      cmake -D CMAKE_INSTALL_COMPONENT="${COMPONENT}" -P cmake_install.cmake
    done

elif [ "${PKG_NAME}" == "librdkit-dev" ]; then

    cmake -D CMAKE_INSTALL_COMPONENT=dev -P cmake_install.cmake

elif [ "${PKG_NAME}" == "rdkit" ]; then

    # NOTE(skearnes): The "extras" component covers the Contrib and Projects directories.
    for COMPONENT in extras python; do
      cmake -D CMAKE_INSTALL_COMPONENT="${COMPONENT}" -P cmake_install.cmake
    done
    cmake --build . --config Release --target stubs

    # NOTE(hadim): Below we run `pip install ...` in order to correctly add the `.dist-info` directory in the package
    # so python can correctly detect whether rdkit is installed when it's coming from a conda package.

    # Set the version for setuptools_scm.
    export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

    # Install the Python library.
    export PYTHONDONTWRITEBYTECODE=1
    ${PYTHON} -m pip install --no-deps --no-index --ignore-installed --no-build-isolation -vv --prefix "${PREFIX}" .

elif [ "${PKG_NAME}" == "rdkit-postgresql" ]; then

    cd ./Code/PgSQL/rdkit
    cmake -P cmake_install.cmake

fi
