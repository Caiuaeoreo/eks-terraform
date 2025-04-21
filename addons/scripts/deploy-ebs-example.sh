#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Checking kubectl Configuration"
kubectl get nodes > /dev/null
if [ $? -ne 0 ]; then
  echo "kubectl is not properly configured. Please run:"
  echo "aws eks update-kubeconfig --region \$(aws configure get region) --name \$(terraform output -raw cluster_name)"
  exit 1
fi

section "Deploying EBS Storage Example"
kubectl apply -f ebs-storage-class.yaml

section "Waiting for Pod"
echo "Waiting for pod to be ready..."
# Achei fantastico usar kubectl wait, não conhecia, recomendo a todo mundo kkkkk
kubectl wait --for=condition=ready pod/app-with-storage --timeout=120s

section "Storage Resources"
echo "Storage Class:"
kubectl get sc ebs-sc -o wide

echo "Persistent Volume Claim:"
kubectl get pvc ebs-claim -o wide

echo "Persistent Volume:"
kubectl get pv -o wide

section "Pod Status"
kubectl get pod app-with-storage -o wide

section "Testing Storage"
echo "Writing test data to the EBS volume..."
kubectl exec -it app-with-storage -- bash -c "echo 'This data is stored on an EBS volume' > /data/test-file.txt"
echo "Reading test data from the EBS volume..."
kubectl exec -it app-with-storage -- cat /data/test-file.txt

section "EBS Storage Example Deployed"
echo "The example application with EBS storage has been successfully deployed!"
echo "You can access the pod with: kubectl exec -it app-with-storage -- bash"
