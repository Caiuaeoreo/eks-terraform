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

install_or_update_addon() {
  local addon_name=$1
  local addon_version=$2
  
  if aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION | grep -q "$addon_name"; then
    echo "Atualizando $addon_name..."
    aws eks update-addon \
      --cluster-name $CLUSTER_NAME \
      --addon-name $addon_name \
      --addon-version $addon_version \
      --resolve-conflicts OVERWRITE \
      --region $REGION
  else
    echo "Instalando $addon_name..."
    aws eks create-addon \
      --cluster-name $CLUSTER_NAME \
      --addon-name $addon_name \
      --addon-version $addon_version \
      --resolve-conflicts OVERWRITE \
      --region $REGION
  fi
}

install_or_update_addon "coredns" "v1.11.4-eksbuild.2"

install_or_update_addon "kube-proxy" "v1.32.0-eksbuild.2"

install_or_update_addon "vpc-cni" "v1.19.2-eksbuild.1"

echo "Criando IAM role para o EBS CSI Driver..."
POLICY_ARN="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

if ! aws iam get-role --role-name $CLUSTER_NAME-ebs-csi-driver &> /dev/null; then
  aws iam create-role \
    --role-name $CLUSTER_NAME-ebs-csi-driver \
    --assume-role-policy-document "$TRUST_POLICY" \
    --description "Role for EBS CSI Driver addon"

  aws iam attach-role-policy \
    --role-name $CLUSTER_NAME-ebs-csi-driver \
    --policy-arn $POLICY_ARN
  
  echo "Role $CLUSTER_NAME-ebs-csi-driver criada com sucesso."
else
  echo "Role $CLUSTER_NAME-ebs-csi-driver já existe."
fi

EBS_CSI_ROLE_ARN=$(aws iam get-role --role-name $CLUSTER_NAME-ebs-csi-driver --query 'Role.Arn' --output text)

install_or_update_addon "aws-ebs-csi-driver" "v1.41.0-eksbuild.1"

section "Verificando addons instalados"
aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION

section "Verificando pods do sistema"
kubectl get pods -n kube-system

section "Instalação de Addons Concluída"
echo "Todos os addons foram instalados com sucesso!"
echo "Para instalar o Istio, execute: ./03-deploy-istio.sh"
