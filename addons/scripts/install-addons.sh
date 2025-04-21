#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Verificando acesso ao cluster"
kubectl get nodes || echo "Não foi possível acessar o cluster. Verifique sua configuração do kubectl." && exit 1

CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text --region us-east-1)
REGION=$(aws configure get region)

section "Instalando addons do EKS"
echo "Cluster: $CLUSTER_NAME"
echo "Região: $REGION"

echo "Instalando CoreDNS..."
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name coredns \
  --addon-version v1.11.4-eksbuild.2 \
  --resolve-conflicts OVERWRITE \
  --region $REGION

echo "Instalando kube-proxy..."
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name kube-proxy \
  --addon-version v1.32.0-eksbuild.2 \
  --resolve-conflicts OVERWRITE \
  --region $REGION

echo "Instalando VPC CNI..."
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name vpc-cni \
  --addon-version v1.19.2-eksbuild.1 \
  --resolve-conflicts OVERWRITE \
  --region $REGION

EBS_CSI_ROLE_ARN=$(aws iam get-role --role-name $CLUSTER_NAME-ebs-csi-driver --query 'Role.Arn' --output text --region $REGION)

echo "Instalando EBS CSI Driver..."
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name aws-ebs-csi-driver \
  --addon-version v1.41.0-eksbuild.1 \
  --service-account-role-arn $EBS_CSI_ROLE_ARN \
  --resolve-conflicts OVERWRITE \
  --region $REGION

section "Verificando addons instalados"
aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION

section "Instalação concluída"
echo "Todos os addons foram instalados com sucesso!"
