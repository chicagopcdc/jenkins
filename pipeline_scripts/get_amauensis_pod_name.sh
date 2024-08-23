#!/bin/bash

pods_output=$(kubectl get pods)

pod_name=$(echo "$pods_output" | grep 'amanuensis-deployment' | awk '{print $1}')

echo $pod_name
