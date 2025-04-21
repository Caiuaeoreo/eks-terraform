#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Verificando acesso ao cluster"
kubectl get nodes || echo "Não foi possível acessar o cluster. Verifique sua configuração do kubectl." && exit 1

ISTIO_DIR="$(dirname "$0")/istio"
ISTIO_VERSION="1.21.0"
ISTIO_DOWNLOAD_DIR="/tmp/istio-${ISTIO_VERSION}"

section "Baixando e instalando Istioctl"
if [ ! -f "${ISTIO_DOWNLOAD_DIR}/bin/istioctl" ]; then
  echo "Baixando Istio ${ISTIO_VERSION}..."
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
  mv istio-${ISTIO_VERSION} ${ISTIO_DOWNLOAD_DIR}
fi

export PATH="${ISTIO_DOWNLOAD_DIR}/bin:$PATH"

istioctl version || echo "Falha ao instalar istioctl. Verifique a instalação." && exit 1

section "Instalando Istio com perfil demo"
istioctl install --set profile=demo -y

section "Habilitando injeção automática de sidecar"
kubectl label namespace default istio-injection=enabled --overwrite

section "Instalando addons de observabilidade"
echo "Instalando Kiali..."
kubectl apply -f ${ISTIO_DOWNLOAD_DIR}/samples/addons/kiali.yaml

echo "Instalando Prometheus..."
kubectl apply -f ${ISTIO_DOWNLOAD_DIR}/samples/addons/prometheus.yaml

echo "Instalando Grafana..."
kubectl apply -f ${ISTIO_DOWNLOAD_DIR}/samples/addons/grafana.yaml

echo "Instalando Jaeger..."
kubectl apply -f ${ISTIO_DOWNLOAD_DIR}/samples/addons/jaeger.yaml

section "Verificando instalação do Istio"
kubectl get pods -n istio-system

#Nessa altura do campeonato eu não lembro mais o b.o que deu aqui mas consegui corrigir, por isso deixei assim. Obs: Aceito sugestões de como melhorar esse bash de deploy.
section "Corrigindo problema do Security Group para o LoadBalancer"
echo "Identificando security groups com tag kubernetes.io/cluster/eks-cluster-dev..."

NODE_SG=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*node*" --query "SecurityGroups[0].GroupId" --output text)

if [ ! -z "$NODE_SG" ]; then
  echo "Removendo tag kubernetes.io/cluster/eks-cluster-dev do security group $NODE_SG..."
  aws ec2 delete-tags --resources $NODE_SG --tags Key=kubernetes.io/cluster/eks-cluster-dev
  echo "Tag removida com sucesso."
else
  echo "Não foi possível identificar o security group do nó."
fi

section "Instalação do Istio Concluída"
echo "Istio foi instalado com sucesso!"
echo "Para implantar a aplicação de exemplo, execute: ./04-deploy-sample-app.sh"
echo ""
echo "Para acessar os dashboards, use os seguintes comandos:"
echo "  Kiali: istioctl dashboard kiali"
echo "  Grafana: istioctl dashboard grafana"
echo "  Jaeger: istioctl dashboard jaeger"
echo "  Prometheus: istioctl dashboard prometheus"
