provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create istio-system namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.21.0"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  depends_on = [
    kubernetes_namespace.istio_system
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.21.0"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  set {
    name  = "global.hub"
    value = "docker.io/istio"
  }

  set {
    name  = "global.tag"
    value = "1.21.0"
  }

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.21.0"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    helm_release.istiod
  ]
}

resource "kubernetes_namespace" "bookinfo" {
  metadata {
    name = "bookinfo"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    helm_release.istiod
  ]
}

resource "helm_release" "kiali_operator" {
  name       = "kiali-operator"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-operator"
  version    = "1.75.0"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  depends_on = [
    helm_release.istio_ingress
  ]
}

resource "kubernetes_manifest" "kiali_server" {
  manifest = {
    apiVersion = "kiali.io/v1alpha1"
    kind       = "Kiali"
    metadata = {
      name      = "kiali"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = {
      deployment = {
        accessible_namespaces = ["**"]
      }
      external_services = {
        prometheus = {
          url = "http://prometheus.istio-system:9090"
        }
      }
    }
  }

  depends_on = [
    helm_release.kiali_operator
  ]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.8.0"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace.istio_system
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.0.19"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 120

  set {
    name  = "persistence.enabled"
    value = "false"
  }

  set {
    name  = "datasources.datasources\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].name"
    value = "Prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].type"
    value = "prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].url"
    value = "http://prometheus-server.istio-system.svc.cluster.local"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].access"
    value = "proxy"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].isDefault"
    value = "true"
  }

  depends_on = [
    helm_release.prometheus
  ]
}

output "istio_ingress_gateway" {
  value = "http://${data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.hostname}:80"
  depends_on = [
    helm_release.istio_ingress
  ]
}

data "kubernetes_service" "istio_ingress" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = kubernetes_namespace.istio_system.metadata[0].name
  }
  depends_on = [
    helm_release.istio_ingress
  ]
}
