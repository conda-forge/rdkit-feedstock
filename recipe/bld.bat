REM Upstream defaults boost to ON and rejects both ON with a FATAL_ERROR, so set both.
if "%wrapper_flavor%"=="boost" (
    set "WRAPPER_FLAGS=-D RDK_BUILD_BOOST_PYTHON_WRAPPERS=ON -D RDK_BUILD_NANOBIND_WRAPPERS=OFF"
) else if "%wrapper_flavor%"=="nanobind" (
    set "WRAPPER_FLAGS=-D RDK_BUILD_BOOST_PYTHON_WRAPPERS=OFF -D RDK_BUILD_NANOBIND_WRAPPERS=ON"
) else (
    echo ERROR: unknown wrapper_flavor '%wrapper_flavor%'
    exit 1
)

REM The build stays in-source because the stub generator imports the extension modules
REM from the source tree. Record Contrib\ and Projects\ before CMake writes into them,
REM since upstream installs both whole; install.bat drops what the build added.
%PYTHON% %RECIPE_DIR%\source_tree_files.py record %SRC_DIR% %SRC_DIR%\source-tree-files.txt Contrib Projects
if errorlevel 1 exit 1

cmake ^
    -G "NMake Makefiles JOM" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D Python3_EXECUTABLE="%PYTHON%" ^
    -D Python_EXECUTABLE="%PYTHON%" ^
    -D PYTHON_INSTDIR="%SP_DIR%" ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    %WRAPPER_FLAGS% ^
    -D RDK_BUILD_CAIRO_SUPPORT=ON ^
    -D RDK_BUILD_CONTRIB=ON ^
    -D RDK_BUILD_CPP_TESTS=OFF ^
    -D RDK_BUILD_FREESASA_SUPPORT=ON ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_PGSQL=ON ^
    -D RDK_BUILD_XYZ2MOL_SUPPORT=ON ^
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON ^
    -D RDK_INSTALL_DLLS_MSVC=ON ^
    -D RDK_INSTALL_DEV_COMPONENT=OFF ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_INSTALL_STATIC_LIBS=OFF ^
    -D RDK_PGSQL_STATIC=OFF ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release -j %CPU_COUNT%
if errorlevel 1 exit 1
