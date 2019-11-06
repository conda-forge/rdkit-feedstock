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
    -D RDK_BUILD_YAEHMOP_SUPPORT=ON ^
	-D RDK_INSTALL_DEV_COMPONENT=OFF ^
    -D RDK_INSTALL_INTREE=OFF ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
