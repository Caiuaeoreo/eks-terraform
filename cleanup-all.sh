#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "WARNING: Complete Cleanup"
echo "This script will remove ALL resources created by this project:"
echo "  - Sample application"
echo "  - Istio service mesh"
echo "  - EKS addons"
echo "  - EKS cluster and all AWS resources"
echo "  - All Terraform state and cache files"
echo ""
echo "This is a DESTRUCTIVE operation and cannot be undone!"
echo ""

read -p "Are you sure you want to perform a complete cleanup? (Type 'yes' to confirm): " confirm
if [[ $confirm != "yes" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

section "Step 1: Cleaning up Sample Application"
if [ -f "sample-app/scripts/cleanup.sh" ]; then
  echo "Running sample application cleanup script..."
  cd sample-app/scripts
  ./cleanup.sh
  cd ../../
else
  echo "Sample application cleanup script not found. Skipping."
fi

section "Step 2: Cleaning up Istio"
if [ -f "istio/scripts/cleanup.sh" ]; then
  echo "Running Istio cleanup script..."
  cd istio/scripts
  ./cleanup.sh
  cd ../../
else
  echo "Istio cleanup script not found. Skipping."
fi

section "Step 3: Cleaning up EKS Addons"
if [ -f "addons/scripts/cleanup.sh" ]; then
  echo "Running EKS addons cleanup script..."
  cd addons/scripts
  ./cleanup.sh
  cd ../../
else
  echo "EKS addons cleanup script not found. Skipping."
fi

section "Step 4: Cleaning up EKS Cluster"
if [ -f "eks/scripts/cleanup.sh" ]; then
  echo "Running EKS cleanup script..."
  cd eks/scripts
  ./cleanup.sh
  cd ../../
else
  echo "EKS cleanup script not found. Skipping."
fi

section "Cleaning up Root Directory Terraform Files"
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

section "Cleanup Complete"
echo "All resources have been removed and Terraform files have been cleaned up."
echo "Your environment is now clean and ready for a fresh deployment."
