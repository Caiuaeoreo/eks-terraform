#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Verificando Configuração da AWS CLI"
if ! command -v aws &> /dev/null; then
  echo "AWS CLI não está instalado. Por favor, instale primeiro."
  exit 1
fi

echo "Verificando credenciais AWS..."
aws sts get-caller-identity
if [ $? -ne 0 ]; then
  echo "Credenciais AWS não estão configuradas corretamente. Execute 'aws configure'."
  exit 1
fi

section "Verificando Instalação do Terraform"
if ! command -v terraform &> /dev/null; then
  echo "Terraform não está instalado. Por favor, instale primeiro."
  exit 1
fi

cd "$(dirname "$0")/eks/terraform"

section "Inicializando Terraform"
terraform init

section "Validando Configuração do Terraform"
terraform validate

section "Planejando Implantação do Terraform"
terraform plan

read -p "Deseja prosseguir com a implantação do EKS? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Implantação cancelada."
  exit 0
fi

section "Implantando Cluster EKS"
terraform apply -auto-approve
#terraform apply -auto-approve -target=module.vpc -target=module.eks.aws_eks_cluster.this -target=module.eks.aws_iam_role.this -target=module.eks.aws_iam_role_policy_attachment.this -target=module.eks.aws_security_group.cluster -target=module.eks.aws_security_group.node -target=module.eks.aws_security_group_rule.cluster -target=module.eks.aws_security_group_rule.node

section "Aguardando o cluster ficar pronto"
echo "Aguardando 60 segundos para o cluster inicializar..."
sleep 60

section "Configurando kubectl"
echo "Atualizando kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)

echo "Verificando conexão com o cluster..."
kubectl get nodes || echo "Não foi possível conectar ao cluster. Aguardando mais 30 segundos..." && sleep 30 && aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name) && kubectl get nodes

section "Informações do Cluster EKS"
echo "Endpoint do Cluster: $(terraform output -raw cluster_endpoint)"
echo "Nome do Cluster: $(terraform output -raw cluster_name)"
echo "Região: us-east-1"
echo "VPC ID: $(terraform output -raw vpc_id)"

section "Implantação do EKS Concluída"
echo "Seu cluster EKS básico foi implantado com sucesso!"
echo "Para instalar os addons, execute: ./02-deploy-addons.sh"
