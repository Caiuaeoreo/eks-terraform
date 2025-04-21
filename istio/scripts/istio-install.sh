#!/bin/bash

set -e

section() {
  echo "========================================="
  echo "  $1"
  echo "========================================="
}

section "Checking kubectl Configuration"
kubectl get nodes > /dev/null
if [ $? -ne 0 ]; then
  echo "kubectl is not properly configured. Please run:"
  echo "aws eks update-kubeconfig --region \$(terraform output -raw region) --name \$(terraform output -raw cluster_name)"
  exit 1
fi

section "Installing Istioctl"
ISTIO_VERSION="1.21.0"
echo "Downloading Istio ${ISTIO_VERSION}..."
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -

cd istio-${ISTIO_VERSION}
export PATH=$PWD/bin:$PATH
cd ..

echo "Verifying istioctl installation..."
istioctl version

section "Installing Istio"
echo "Installing Istio with demo profile..."
istioctl install --set profile=demo -y

section "Enabling Sidecar Injection"
echo "Enabling automatic sidecar injection for default namespace..."
kubectl label namespace default istio-injection=enabled

section "Installing Istio Addons"
echo "Installing Kiali, Prometheus, Grafana, and Jaeger..."
kubectl apply -f istio-${ISTIO_VERSION}/samples/addons/kiali.yaml
kubectl apply -f istio-${ISTIO_VERSION}/samples/addons/prometheus.yaml
kubectl apply -f istio-${ISTIO_VERSION}/samples/addons/grafana.yaml
kubectl apply -f istio-${ISTIO_VERSION}/samples/addons/jaeger.yaml

echo "Waiting for addons to be ready..."
kubectl rollout status deployment/kiali -n istio-system
kubectl rollout status deployment/prometheus -n istio-system
kubectl rollout status deployment/grafana -n istio-system

section "Deploying Bookinfo Sample Application"
echo "Deploying Bookinfo sample application..."
kubectl apply -f istio-${ISTIO_VERSION}/samples/bookinfo/platform/kube/bookinfo.yaml

echo "Creating Istio gateway for Bookinfo..."
kubectl apply -f istio-${ISTIO_VERSION}/samples/bookinfo/networking/bookinfo-gateway.yaml

echo "Waiting for Bookinfo services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/productpage-v1 deployment/details-v1 deployment/ratings-v1 deployment/reviews-v1 deployment/reviews-v2 deployment/reviews-v3

section "Istio Ingress Gateway"
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo "Istio Ingress Gateway URL: http://$GATEWAY_URL"
echo "Bookinfo Application URL: http://$GATEWAY_URL/productpage"
echo "Kiali Dashboard: http://$GATEWAY_URL:20001"

section "Dashboard Access Commands"
echo "To access Kiali dashboard, run:"
echo "istioctl dashboard kiali"
echo ""
echo "To access Grafana dashboard, run:"
echo "istioctl dashboard grafana"
echo ""
echo "To access Jaeger dashboard, run:"
echo "istioctl dashboard jaeger"
echo ""
echo "To access Prometheus dashboard, run:"
echo "istioctl dashboard prometheus"

section "Istio Installation Complete"
echo "Istio has been successfully installed on your EKS cluster!"
echo "The Bookinfo sample application has been deployed."
echo "You can access the application at: http://$GATEWAY_URL/productpage"
