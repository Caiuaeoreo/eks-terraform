#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Verificando acesso ao cluster"
kubectl get nodes || echo "Não foi possível acessar o cluster. Verifique sua configuração do kubectl." && exit 1

section "Verificando instalação do Istio"
kubectl get pods -n istio-system || echo "Istio não parece estar instalado. Execute ./03-deploy-istio.sh primeiro." && exit 1

SAMPLE_APP_DIR="$(dirname "$0")/sample-app"

section "Implantando aplicação Nginx com Istio"
${SAMPLE_APP_DIR}/scripts/deploy.sh

section "Verificando implantação"
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

if [ -n "$INGRESS_HOST" ]; then
  echo "Testando o endpoint principal..."
  echo "URL da aplicação: http://$GATEWAY_URL/"
  
  echo "Testando o endpoint /ping..."
  echo "Executando: curl -s http://$GATEWAY_URL/ping"
  curl -s http://$GATEWAY_URL/ping || echo "Não foi possível acessar o endpoint /ping"
  
  echo ""
  echo "Para visualizar o tráfego no Kiali, execute: istioctl dashboard kiali"
else
  echo "Aviso: Não foi possível obter o endereço do Load Balancer."
  echo "Verifique o status do serviço istio-ingressgateway:"
  kubectl describe svc -n istio-system istio-ingressgateway
fi

section "Informações de acesso"
echo "Para acessar a aplicação, use: http://$GATEWAY_URL/"
echo "Para testar o endpoint ping, use: http://$GATEWAY_URL/ping"
echo ""
echo "Para remover a aplicação, execute: ${SAMPLE_APP_DIR}/scripts/cleanup.sh"
