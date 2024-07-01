echo PKG_NAME is %PKG_NAME%

if %PKG_NAME%==librdkit (
    echo Installing librdkit
    set components=Unspecified base data dev docs extras runtime
    for %%C in (%components%) do (
        echo Installing librdkit component %%C
        cmake -D CMAKE_INSTALL_COMPONENT=%%C -P cmake_install.cmake
        if errorlevel 1 exit 1
    )
    copy bin\*.dll %LIBRARY_BIN%
)

if %PKG_NAME%==rdkit (
    echo Installing rdkit
    cmake -D CMAKE_INSTALL_COMPONENT=python -P cmake_install.cmake
    if errorlevel 1 exit 1
    cmake --build . --config Release --target stubs
    if errorlevel 1 exit 1

    @REM NOTE(hadim): Below we run `pip install ...` in order to correctly add the `.dist-info` directory in the package
    @REM so python can correctly detect whether rdkit is installed when it's coming from a conda package.

    @REM Set the version for setuptools_scm.
    set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

    @REM Install the Python library.
    %PYTHON% -m pip install --no-deps -vv --no-build-isolation --prefix %PREFIX% .
)

if %PKG_NAME%==rdkit-dev (
    echo Installing rdkit-dev
    echo Copying libs and headers

    if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
    if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%

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

if %PKG_NAME%==rdkit-postgresql (
    echo Installing rdkit-postgresql
    cd Code\PgSQL\rdkit
    cmake -P cmake_install.cmake
    if errorlevel 1 exit 1
)
