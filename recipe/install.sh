#!/bin/bash

set -euxo pipefail

if [[ $PKG_NAME == "librdkit" ]]; then

    # Remove python library.
    ${PYTHON} -m pip uninstall -y -vv rdkit
    # Remove PostgreSQL extension.
    rm -v "${PREFIX}/share/extension/rdkit*" "${PREFIX}/lib/rdkit.so"

elif [[ $PKG_NAME == "rdkit" ]]; then

    # Remove librdkit.
    # TODO(skearnes)
    # Remove PostgreSQL extension.
    rm -v "${PREFIX}/share/extension/rdkit*" "${PREFIX}/lib/rdkit.so"

elif [[ $PKG_NAME == "rdkit-postgresql" ]]; then

    # Remove librdkit.
    # TODO(skearnes)
    # Remove python library.
    ${PYTHON} -m pip uninstall -y -vv rdkit

fi
