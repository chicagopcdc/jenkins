#!/bin/bash
# pcdc kubeconfig file
cat /home/ubuntu/Gen3Secrets/kubeconfig

kubectl config view

# Get jenkins-service account token for setting jenkins kubernetes agent credential
kubectl describe secret $(kubectl describe serviceaccount jenkins-service --namespace=default | grep Token | awk '{print $2}') --namespace=default

kubectl get rolebindings --namespace default

kubectl describe rolebinding devops-binding --namespace default
