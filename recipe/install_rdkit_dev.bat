echo "Copying libs and headers"

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%

REM what's in the lib directory?
dir lib

REM copy .lib files to LIBRARY_LIB
copy lib\*.lib %LIBRARY_LIB%

REM copy .dll files to LIBRARY_BIN
if not exist "%LIBRARY_BIN%" mkdir %LIBRARY_BIN%
copy lib\*.dll %LIBRARY_BIN%

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
