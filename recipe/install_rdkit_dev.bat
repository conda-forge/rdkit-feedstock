echo "Copying libs and headers"

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%

REM copy .lib files to LIBRARY_LIB
copy lib\*.lib %LIBRARY_LIB%

REM copy .h files to LIBRARY_INC
mkdir %LIBRARY_INC%\rdkit
xcopy /y /s Code\*.h %LIBRARY_INC%\rdkit
