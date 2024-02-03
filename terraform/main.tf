terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
  backend "local" {}
}

provider "kubernetes" {
}

resource "random_integer" "number" {
  min = 1
  max = 10
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "${var.deployment_name}-${random_integer.number.result}"
    labels = {
      app = var.label_name
    }
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.label_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.label_name
        }
      }

      spec {
        container {
          image = "${var.image_name}:${var.tag}"
          name  = var.container_name
          port {
            container_port = var.http_container_port
          }

          port {
            container_port = var.https_container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "${var.service_name}-${random_integer.number.result}"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.label_name
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 443
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}