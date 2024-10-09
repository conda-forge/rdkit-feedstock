echo PKG_NAME is %PKG_NAME%

if %PKG_NAME%==librdkit (
    echo Installing librdkit

    REM NOTE(skearnes): List is from `make list_install_components`, excluding "dev", "docs", "python", and "pgsql".
    for %%x in (Unspecified base data extras runtime) do (
        echo Installing librdkit component %%x
        cmake -D CMAKE_INSTALL_COMPONENT=%%x -P cmake_install.cmake
        if errorlevel 1 exit 1
    )

    copy bin\*.dll %LIBRARY_BIN%
    REM Remove python-only libraries.
    del %LIBRARY_BIN%\RDKitRDBoost.dll
)

if %PKG_NAME%==librdkit-dev (
    echo Installing librdkit-dev
    echo Copying libs and headers

    if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
    if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%

    cmake -D CMAKE_INSTALL_COMPONENT=dev -P cmake_install.cmake

    REM copy .lib files to LIBRARY_LIB
    copy lib\*.lib %LIBRARY_LIB%

    REM copy .h files to LIBRARY_INC
    mkdir %LIBRARY_INC%\rdkit
    xcopy /y /s Code\*.h %LIBRARY_INC%\rdkit

    REM copy external .h files to LIBRARY_INC
    xcopy /y External\INCHI-API\*.h %LIBRARY_INC%\rdkit\GraphMol
    xcopy /y External\AvalonTools\*.h %LIBRARY_INC%\rdkit\GraphMol
    xcopy /y External\FreeSASA\*.h %LIBRARY_INC%\rdkit\GraphMol
    xcopy /y External\CoordGen\*.h %LIBRARY_INC%\rdkit\GraphMol
    xcopy /y External\YAeHMOP\*.h %LIBRARY_INC%\rdkit\GraphMol
    xcopy /y External\RingFamilies\RingDecomposerLib\src\RingDecomposerLib\RingDecomposerLib.h %LIBRARY_INC%\rdkit
)

if %PKG_NAME%==rdkit (
    echo Installing rdkit

    REM Copy python-only libraries.
    copy bin\RDKitRDBoost.dll %LIBRARY_BIN%

    cmake -D CMAKE_INSTALL_COMPONENT=python -P cmake_install.cmake
    if errorlevel 1 exit 1
    cmake --build . --config Release --target stubs
    if errorlevel 1 exit 1

    REM NOTE(hadim): Below we run `pip install ...` in order to correctly add the `.dist-info` directory in the package
    REM so python can correctly detect whether rdkit is installed when it's coming from a conda package.

    REM Set the version for setuptools_scm.
    set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

    REM Install the Python library.
    set PYTHONDONTWRITEBYTECODE=1
    %PYTHON% -m pip install --no-deps --no-index --ignore-installed --no-build-isolation -vv --prefix %PREFIX% .
)

if %PKG_NAME%==rdkit-postgresql (
    echo Installing rdkit-postgresql

    cd Code\PgSQL\rdkit
    cmake -P cmake_install.cmake
    if errorlevel 1 exit 1

    REM NOTE(skearnes): The path to rdkit.dll in pgsql_install.bat is wrong. This line should support the generator
    REM "NMake Makefiles JOM": https://github.com/rdkit/rdkit/blob/master/Code/PgSQL/rdkit/CMakeLists.txt#L238.
    xcopy /y rdkit.dll %LIBRARY_LIB%
)
