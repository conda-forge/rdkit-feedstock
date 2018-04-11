cmake ^
    -G "NMake Makefiles JOM" ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_USE_FLEXBISON=OFF ^
    -D Python_ADDITIONAL_VERSIONS=${PY_VER} ^
    -D PYTHON_EXECUTABLE:PATH="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    -D PYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -D PYTHON_INSTDIR:PATH="%SP_DIR%" ^
    -D BOOST_ROOT:PATH="%LIBRARY_PREFIX%" ^
    -D Boost_NO_SYSTEM_PATHS=ON ^
    -D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D RDK_BUILD_CPP_TESTS=OFF ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
