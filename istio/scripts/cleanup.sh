#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Checking kubectl"
if ! command -v kubectl &> /dev/null; then
  echo "kubectl is not installed. Please install it first."
  exit 1
fi

section "Checking istioctl"
if ! command -v istioctl &> /dev/null; then
  echo "istioctl is not installed. Please install it first."
  exit 1
fi

section "WARNING: Istio Removal"
echo "This script will remove Istio and all its components from your cluster."
echo "All Istio-related resources will be deleted."
echo ""

read -p "Are you sure you want to remove Istio? (Type 'yes' to confirm): " confirm
if [[ $confirm != "yes" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

section "Removing Istio Addons"
echo "Removing Kiali..."
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml --ignore-not-found=true

echo "Removing Prometheus..."
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml --ignore-not-found=true

echo "Removing Grafana..."
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml --ignore-not-found=true

echo "Removing Jaeger..."
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml --ignore-not-found=true

section "Removing Namespace Labels"
kubectl label namespace default istio-injection- --ignore-not-found=true

section "Uninstalling Istio"
istioctl uninstall --purge -y

kubectl delete namespace istio-system --ignore-not-found=true

section "Cleaning up Terraform files"
if [ -d "../terraform" ]; then
  cd ../terraform
  if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
  fi
  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
fi

section "Cleanup Complete"
echo "Istio and all its components have been removed from your cluster."
echo "Terraform state and cache files have been removed."
