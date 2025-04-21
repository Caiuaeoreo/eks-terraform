#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

SCRIPT_DIR="$(dirname "$0")"
MANIFESTS_DIR="${SCRIPT_DIR}/../manifests"

section "Verificando acesso ao cluster"
kubectl get nodes || echo "Não foi possível acessar o cluster. Verifique sua configuração do kubectl." && exit 1

section "Verificando instalação do Istio"
kubectl get pods -n istio-system || echo "Istio não parece estar instalado. Execute o script de instalação do Istio primeiro." && exit 1

section "Configurando namespace"
kubectl create namespace nginx-sample --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace nginx-sample istio-injection=enabled --overwrite

section "Implantando aplicação Nginx"
kubectl apply -f ${MANIFESTS_DIR}/nginx-configmap.yaml -n nginx-sample
kubectl apply -f ${MANIFESTS_DIR}/nginx-deployment.yaml -n nginx-sample
kubectl apply -f ${MANIFESTS_DIR}/nginx-service.yaml -n nginx-sample

echo "Verificando implantação da aplicação..."
kubectl get pods -n nginx-sample

echo "Aguardando todos os pods estarem rodando..."
kubectl wait --for=condition=Ready pods --all -n nginx-sample --timeout=300s

section "Configurando Istio Gateway e VirtualService"
kubectl apply -f ${MANIFESTS_DIR}/istio-gateway.yaml -n nginx-sample

section "Obtendo URL do Istio Ingress Gateway"
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo "Aguardando o Load Balancer ficar pronto..."
RETRY_COUNT=0
MAX_RETRIES=30

while [ -z "$INGRESS_HOST" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  sleep 10
  RETRY_COUNT=$((RETRY_COUNT+1))
  echo "Tentativa $RETRY_COUNT de $MAX_RETRIES..."
  export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done

if [ -z "$INGRESS_HOST" ]; then
  echo "Aviso: Não foi possível obter o endereço do Load Balancer após $MAX_RETRIES tentativas."
  echo "Verifique o status do serviço istio-ingressgateway:"
  kubectl describe svc -n istio-system istio-ingressgateway
else
  echo "Load Balancer pronto: $INGRESS_HOST"
fi

section "Implantação da Aplicação Concluída"
echo "A aplicação Nginx foi implantada com sucesso!"
echo ""
echo "URL da aplicação: http://$GATEWAY_URL/"
echo "URL do endpoint ping: http://$GATEWAY_URL/ping"
echo ""
echo "Para testar o endpoint ping, execute: curl http://$GATEWAY_URL/ping"
echo "Para visualizar o tráfego no Kiali, execute: istioctl dashboard kiali"
