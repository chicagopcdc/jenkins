#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No amanuensis pod name provided"
    exit 1
fi

POD_NAME=$1
echo "POD_NAME: ${POD_NAME}"

kubectl exec -i $POD_NAME -- sh -c "
    cd /amanuensis/ &&
    ls -a &&
    poetry install &&
    pytest tests_endpoints/resources
"