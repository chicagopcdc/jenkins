#!/bin/bash

gen3 kube-setup-amanuensis
sleep 5

POD_IMAGE=$(kubectl describe pod $POD_NAME | grep "Image:" | awk '{print $2}')
echo $POD_IMAGE

