#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Checking AWS CLI Configuration"
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it first."
  exit 1
fi

echo "Verifying AWS credentials..."
aws sts get-caller-identity
if [ $? -ne 0 ]; then
  echo "AWS credentials are not properly configured. Please run 'aws configure'."
  exit 1
fi

section "Checking Terraform Installation"
if ! command -v terraform &> /dev/null; then
  echo "Terraform is not installed. Please install it first."
  exit 1
fi

section "WARNING: Cluster Destruction"
echo "This script will destroy the EKS cluster and all associated resources."
echo "All deployed applications and data will be permanently deleted."
echo ""

read -p "Are you sure you want to destroy the EKS cluster? (Type 'yes' to confirm): " confirm
if [[ $confirm != "yes" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

cd ../terraform

section "Destroying EKS Cluster"
terraform destroy -auto-approve

section "Cleaning up Terraform files"
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

section "Cleanup Complete"
echo "Your EKS cluster and all associated resources have been destroyed."
echo "Terraform state and cache files have been removed."
