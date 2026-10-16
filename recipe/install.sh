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
    "${PYTHON}" "${RECIPE_DIR}/source_tree_files.py" prune "${PREFIX}/share/RDKit" "${SRC_DIR}/source-tree-files.txt" Contrib Projects

    # Upstream generates stubs only for Boost.Python. The flavor comes from the build
    # tree rather than the variant variable: conda-build hashes every variable this
    # script names into librdkit too, which must stay one package for all flavors.
    if grep -q '^RDK_BUILD_BOOST_PYTHON_WRAPPERS:BOOL=ON$' CMakeCache.txt; then
      if [ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]; then
        # The generator imports the new extension modules, which the build machine's
        # Python cannot load, so cross-compiled builds ship no stubs.
        echo "Skipping rdkit-stubs when cross-compiling"
      else
        cmake --build . --config Release --target stubs
        # Upstream reports a failed generation only as a message.
        test -f "${SP_DIR}/rdkit-stubs/Chem/rdchem.pyi"
      fi
    fi

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
