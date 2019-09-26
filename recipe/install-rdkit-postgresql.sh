#!/bin/bash

# in case there are any old psql builds: remove them

cd ./Code/PgSQL/rdkit

/bin/bash -e ./pgsql_install.sh

export PGPORT=54321
export PGDATA=${SRC_DIR}/pgdata

rm -rf $PGDATA # cleanup required when building variants
pg_ctl initdb

# ensure that the rdkit extension is loaded at process startup
echo "shared_preload_libraries = 'rdkit'" >> $PGDATA/postgresql.conf

pg_ctl start -l $PGDATA/log.txt

# wait a few seconds just to make sure that the server has started
sleep 2

set +e
ctest
check_result=$?
set -e

pg_ctl stop

exit $check_result