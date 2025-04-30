#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No amanuensis pod name provided"
    exit 1
fi

POD_NAME=$1
echo "POD_NAME: ${POD_NAME}"

kubectl exec -i $POD_NAME -- sh -c "
    cd /fence/tests/login &&
    ls -a &&
    python test_login_user.py
"