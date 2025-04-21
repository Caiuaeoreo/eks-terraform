#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

REGION=$(aws configure get region)

section "Checking kubectl"
if ! command -v kubectl &> /dev/null; then
  echo "kubectl is not installed. Please install it first."
  exit 1
fi

section "Checking AWS CLI"
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it first."
  exit 1
fi

section "WARNING: Addons Removal"
echo "This script will remove EKS addons and clean up Terraform files."
echo ""

read -p "Are you sure you want to remove EKS addons? (Type 'yes' to confirm): " confirm
if [[ $confirm != "yes" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text --region $REGION)
if [ -z "$CLUSTER_NAME" ]; then
  echo "No EKS cluster found. Skipping addon removal."
else
  section "Removing EBS CSI Driver"
  aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver --preserve || true
  
  #Remove other addons if needed
  #aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name vpc-cni --preserve || true
  #aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name kube-proxy --preserve || true
  #aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name coredns --preserve || true
fi

section "Cleaning up Terraform files"
if [ -d "../terraform" ]; then
  cd ../terraform
  if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
  fi
  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
fi

section "Cleanup Complete"
echo "EKS addons have been removed and Terraform files have been cleaned up."
