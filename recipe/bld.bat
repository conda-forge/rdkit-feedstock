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