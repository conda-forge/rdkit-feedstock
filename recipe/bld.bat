cmake ^
    -G "NMake Makefiles JOM" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D BOOST_ROOT="%LIBRARY_PREFIX%" ^
    -D Boost_NO_SYSTEM_PATHS=ON ^
    -D Boost_NO_BOOST_CMAKE=ON ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    -D PYTHON_INSTDIR="%SP_DIR%" ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_BUILD_CAIRO_SUPPORT=ON ^
    -D RDK_BUILD_CPP_TESTS=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_FREESASA_SUPPORT=ON ^
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON ^
    -D RDK_BUILD_XYZ2MOL_SUPPORT=ON ^
    -D RDK_INSTALL_STATIC_LIBS=OFF ^
    -D RDK_INSTALL_DLLS_MSVC=ON ^
    -D RDK_INSTALL_DEV_COMPONENT=OFF ^
    -D RDK_INSTALL_INTREE=OFF ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

REM copy .dll files to LIBRARY_BIN
copy bin\*.dll %LIBRARY_BIN%

@REM NOTE(ptosco): build and install rdkit-stubs
cmake --build . --config Release --target stubs
if errorlevel 1 exit 1

@REM NOTE(hadim): below we run `pip install ...` in order
@REM to correctly add the `.dist-info` directory in the package
@REM so python can correctly detect whether rdkit is installed
@REM when it's coming from a conda package.

@REM Set the version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

@REM Install the Python library
%PYTHON% -m pip install --no-deps -vv --no-build-isolation --prefix %PREFIX% .
