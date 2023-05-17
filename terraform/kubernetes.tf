provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

resource "kubernetes_deployment" "sac-petstore-app" {
  metadata {
    name   = "sac-petstore-app"
    labels = {
      app = "sac-petstore-app"
    }
  }

  spec {
    replicas = 3

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
        container {
          image = "892935461155.dkr.ecr.ap-southeast-1.amazonaws.com/sac-petstore-app:1.0.0"
          name  = "sac-petstore-app"

          ports {
            container_port = 8080
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "development"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sac-petstore-app" {
  metadata {
    name = "sac-petstore-app"
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
}
