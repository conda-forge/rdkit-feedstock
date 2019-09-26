
%PYTHON% "%RECIPE_DIR%\pkg_version.py"

cd "%SRC_DIR%\Code\PgSQL\rdkit"

call pgsql_install.bat

set PGPORT=54321
set PGDATA=%SRC_DIR%\pgdata

pg_ctl initdb

rem ensure that the rdkit extension is loaded at process startup
echo shared_preload_libraries = 'rdkit' >> %PGDATA%\postgresql.conf

pg_ctl -D %PGDATA% -l %PGDATA%/log.txt start

rem wait a few seconds just to make sure that the server has started
timeout /t 2 /nobreak > NUL

ctest -V
set check_result=%ERRORLEVEL%

pg_ctl stop

exit /b %check_result%
