provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_cluster_role" "namespace_creator" {
  metadata {
    name = "namespace-creator"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "namespace_creator_binding" {
  metadata {
    name = "namespace-creator-binding"
  }

  role_ref {
    kind     = "ClusterRole"
    name     = kubernetes_cluster_role.namespace_creator.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "sac-service-account"
    api_group = ""
  }
}

resource "kubernetes_namespace" "sac-petstore-ns" {
  metadata {
    name = "sac-petstore-app"
  }
}

resource "kubernetes_service_account" "sac_service_account" {
  metadata {
    name = "sac-service-account"
    namespace = kubernetes_namespace.sac-petstore-ns.metadata.0.name
  }
}

resource "kubernetes_service" "sac-petstore-app_lb" {
  metadata {
    name = "sac-petstore-app-lb"
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8080
    }

    selector = {
      app = kubernetes_deployment.sac-petstore-app.metadata.0.labels.app
    }
  }
}

resource "kubernetes_deployment" "sac-petstore-app" {
  metadata {
    name   = "sac-petstore-app"
    namespace = kubernetes_namespace.sac-petstore-ns.metadata.0.name
    labels = {
      app = "sac-petstore-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "sac-petstore-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "sac-petstore-app"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.sac_service_account.metadata.0.name

        container {
          image = "892935461155.dkr.ecr.ap-southeast-1.amazonaws.com/sac-petstore-app:1.0.0"
          name  = "sac-petstore-app"

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "development"
          }
        }
      }
    }
  }
}

/*resource "kubernetes_service" "sac-petstore-app" {
  metadata {
    name = "sac-petstore-app"
    namespace = kubernetes_namespace.sac-petstore-ns.metadata.0.name
  }

  spec {
    selector = {
      app = "sac-petstore-app"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
  }
}*/

