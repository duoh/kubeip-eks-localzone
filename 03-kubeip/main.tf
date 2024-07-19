provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "kubeip_lz_cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "kubeip_lz_cluster_auth" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.kubeip_lz_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.kubeip_lz_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.kubeip_lz_cluster_auth.token
}

resource "aws_eip" "kubeip" {
  count = 1

  tags = {
    Name        = "kubeip-${count.index}"
    environment = "demo"
    kubeip      = "reserved"
  }

  network_border_group = var.network_border_group
}

resource "kubernetes_service_account" "kubeip_service_account" {
  metadata {
    name        = var.kubeip_sa_name
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.kubeip_role_arn
    }
  }
}

resource "kubernetes_cluster_role" "kubeip_cluster_role" {
  metadata {
    name = "kubeip-cluster-role"
  }
  rule {
    api_groups = ["*"]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "delete", "get"]
  }
}

resource "kubernetes_cluster_role_binding" "kubeip_cluster_role_binding" {
  metadata {
    name = "kubeip-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubeip_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubeip_service_account.metadata[0].name
    namespace = kubernetes_service_account.kubeip_service_account.metadata[0].namespace
  }
}

resource "kubernetes_daemonset" "kubeip_daemonset" {
  metadata {
    name      = "kubeip-agent"
    namespace = "kube-system"
    labels    = {
      app = "kubeip"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "kubeip"
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
      }
    }
    template {
      metadata {
        labels = {
          app = "kubeip"
        }
      }
      spec {
        service_account_name             = var.kubeip_sa_name
        termination_grace_period_seconds = 30
        priority_class_name              = "system-node-critical"
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
        container {
          name  = "kubeip-agent"
          image = "doitintl/kubeip-agent"
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name  = "FILTER"
            value = "Name=tag:kubeip,Values=reserved;Name=tag:environment,Values=demo"
          }
          env {
            name  = "LOG_LEVEL"
            value = "info"
          }
          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }
        }
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "public-lz-ng"
          kubeip = "use"
        }
      }
    }
  }
  depends_on = [kubernetes_service_account.kubeip_service_account]
}