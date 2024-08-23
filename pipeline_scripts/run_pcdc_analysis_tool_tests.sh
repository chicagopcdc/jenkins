#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No amanuensis pod name provided"
    exit 1
fi

POD_NAME=$1
echo "POD_NAME: ${POD_NAME}"

kubectl exec -i $POD_NAME -- sh -c "
    cd /PcdcAnalysisTools/ &&
    ls -a &&
    poetry install &&

    export Full_DATA_PATH=/PcdcAnalysisTools/tests/test_data/data.json &&
    export SHORT_DATA_PATH=/PcdcAnalysisTools/tests/test_data/data_short.json &&
    export NO_DATA_PATH=/PcdcAnalysisTools/tests/test_data/no_data.json &&
    export DATA_PATH=/PcdcAnalysisTools/tests/test_data/data_short_stats.json &&
    export Short_DATA_SURVIVAL_PATH=/PcdcAnalysisTools/tests/test_data/data_short_survival.json &&
    export Short_DATA_STATS_PATH=/PcdcAnalysisTools/tests/test_data/data_short_stats.json &&
    export SHORT_DATA_EXTERNAL_PATH=/PcdcAnalysisTools/tests/test_data/data_external.json &&
    export MOCK_DATA=True &&

    pytest tests/endpoint.py
"