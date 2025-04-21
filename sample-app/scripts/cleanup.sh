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

section "Removendo Gateway e VirtualService"
kubectl delete -f ${MANIFESTS_DIR}/istio-gateway.yaml -n nginx-sample --ignore-not-found=true

section "Removendo aplicação Nginx"
kubectl delete -f ${MANIFESTS_DIR}/nginx-service.yaml -n nginx-sample --ignore-not-found=true
kubectl delete -f ${MANIFESTS_DIR}/nginx-deployment.yaml -n nginx-sample --ignore-not-found=true
kubectl delete -f ${MANIFESTS_DIR}/nginx-configmap.yaml -n nginx-sample --ignore-not-found=true

section "Removendo namespace"
kubectl delete namespace nginx-sample --ignore-not-found=true

section "Limpeza Concluída"
echo "A aplicação Nginx e todos os recursos associados foram removidos com sucesso!"
