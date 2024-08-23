#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No amanuensis pod name provided"
    exit 1
fi

POD_NAME=$1
echo "POD_NAME: ${POD_NAME}"

kubectl exec -i $POD_NAME -- sh -c "
    cd /sheepdog/ &&
    ls -a &&
    poetry install &&

    export PGHOST=pcdc-dev-gdcapidb.cr610l8znapz.us-east-1.rds.amazonaws.com
    export PGUSER=test
    export PGPASSWORD=test
    export PGDATABASE=gdcapi
    export PGPORT=5432

    vi /sheepdog/tests/ci_setup.sh的host, user, passwd
    vi /sheepdog/tests/integration/datadict/conftest.py
      # update these settings if you want to point to another db
      def pg_config(use_ssl=False, isolation_level=None):
          test_host = (
              "localhost:" + str(os.environ.get("PGPORT"))
              if os.environ.get("PGPORT") is not None
              else "localhost"
          )
    vi sheepdog/bin/setup_transactionlogs.py
    vi tests/integration/datadictwithobjid/conftest.py
"