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

section "Initializing Terraform"
terraform init

section "Validating Terraform Configuration"
terraform validate

section "Planning Terraform Deployment"
terraform plan

read -p "Deseja prosseguir com a implantação? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Implantação cancelada."
  exit 0
fi

section "Implantando Cluster EKS (Fase 1)"
terraform apply -auto-approve -target=module.vpc -target=module.eks.aws_eks_cluster.this -target=module.eks.aws_iam_role.this -target=module.eks.aws_iam_role_policy_attachment.this -target=module.eks.aws_security_group.cluster -target=module.eks.aws_security_group.node -target=module.eks.aws_security_group_rule.cluster -target=module.eks.aws_security_group_rule.node

section "Aguardando o cluster ficar pronto"
echo "Aguardando 60 segundos para o cluster inicializar..."
sleep 60

section "Configurando kubectl"
echo "Atualizando kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)

#echo "Verificando conexão com o cluster..."
#kubectl get nodes || {
#  echo "Não foi possível conectar ao cluster. Aguardando mais 30 segundos..."
#  sleep 30
#  aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)
#  kubectl get nodes
#}

section "Implantando recursos restantes (Fase 2)"
terraform apply -auto-approve

sleep 10

section "Verificando Cluster EKS"
echo "Verificando nós..."
kubectl get nodes

echo "Verificando serviços Kubernetes..."
kubectl get svc

section "Informações do Cluster EKS"
echo "Endpoint do Cluster: $(terraform output -raw cluster_endpoint)"
echo "Nome do Cluster: $(terraform output -raw cluster_name)"
echo "Região: us-east-1"
echo "VPC ID: $(terraform output -raw vpc_id)"

section "Implantação Concluída"
echo "Seu cluster EKS foi implantado com sucesso!"
echo "Para implantar aplicações com balanceadores de carga, crie serviços Kubernetes do tipo LoadBalancer."
echo "Após a implantação, obtenha o nome DNS do balanceador de carga com: kubectl get svc -o wide | grep LoadBalancer"
