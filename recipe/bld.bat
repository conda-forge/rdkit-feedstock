cmake ^
    -G "NMake Makefiles JOM" ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_BUILD_PYTHON_WRAPPERS=ON ^
    -D RDK_USE_FLEXBISON=OFF ^
    -D RDK_BUILD_CAIRO_SUPPORT=ON ^
    -D RDK_BUILD_THREADSAFE_SSS=ON ^
    -D RDK_BUILD_CPP_TESTS=OFF ^
    -D Python_ADDITIONAL_VERSIONS=${PY_VER} ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR="%PREFIX%\include" ^
    -D PYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -D PYTHON_INSTDIR="%SP_DIR%" ^
    -D BOOST_ROOT="%LIBRARY_PREFIX%" ^
    -D Boost_NO_SYSTEM_PATHS=ON ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
