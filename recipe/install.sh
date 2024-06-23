#!/bin/bash

set -euxo pipefail

if [[ $PKG_NAME == "librdkit" ]]; then

    # Remove python library.
    rm -rf "${PREFIX}/lib/python3*/site-packages/rdkit"
    # Remove PostgreSQL extension.
    rm -f "${PREFIX}/share/extension/rdkit*" "${PREFIX}/lib/rdkit.so"

elif [[ $PKG_NAME == "rdkit" ]]; then

    # Remove PostgreSQL extension.
    rm -f "${PREFIX}/share/extension/rdkit*" "${PREFIX}/lib/rdkit.so"
    # NOTE(ptosco): build and install rdkit-stubs
    cmake --build . --config Release --target stubs

    # NOTE(hadim): below we run `pip install ...` in order
    # to correctly add the `.dist-info` directory in the package
    # so python can correctly detect whether rdkit is installed
    # when it's coming from a conda package.

    # Set the version for setuptools_scm
    echo "Setting SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION"
    export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"

    # Install the Python library
    ${PYTHON} -m pip install --no-deps -vv --no-build-isolation --prefix ${PREFIX} .

elif [[ $PKG_NAME == "rdkit-postgresql" ]]; then

    # Remove python library.
    rm -rf "${PREFIX}/lib/python3*/site-packages/rdkit"

fi
