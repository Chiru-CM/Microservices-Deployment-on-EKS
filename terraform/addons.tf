# =============================================================================
# EKS ADD-ONS AND EXTENSIONS
# =============================================================================

module "eks_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  # Cluster information
  cluster_name      = module.retail_app_eks.cluster_name
  cluster_endpoint  = module.retail_app_eks.cluster_endpoint
  cluster_version   = module.retail_app_eks.cluster_version
  oidc_provider_arn = module.retail_app_eks.oidc_provider_arn

  # =============================================================================
  # NGINX INGRESS CONTROLLER - Load Balancing and Routing
  # =============================================================================
  enable_ingress_nginx = true
  ingress_nginx = {
    most_recent = true
    namespace   = "ingress-nginx"

    # Basic configuration
    set = [
      {
        name  = "controller.service.type"
        value = "LoadBalancer"
      },
      {
        name  = "controller.service.externalTrafficPolicy"
        value = "Local"
      },
      {
        name  = "controller.resources.requests.cpu"
        value = "100m"
      },
      {
        name  = "controller.resources.requests.memory"
        value = "128Mi"
      },
      {
        name  = "controller.resources.limits.cpu"
        value = "200m"
      },
      {
        name  = "controller.resources.limits.memory"
        value = "256Mi"
      }
    ]

    # AWS Load Balancer specific annotations
    set_sensitive = [
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
        value = "internet-facing"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "nlb"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
        value = "instance"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-path"
        value = "/healthz"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-port"
        value = "10254"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-protocol"
        value = "HTTP"
      }
    ]
  }

  # =============================================================================
  # OPTIONAL: MONITORING STACK
  # =============================================================================
  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    most_recent = true
    namespace   = "monitoring"
    values = [yamlencode({

      # Grafana configuration
      grafana = {
        enabled = true
        service = {
          type = "ClusterIP"
        }
        # Admin credentials
        adminPassword = "admin123" 

        # Import community dashboards automatically
        dashboardProviders = {
          "dashboardproviders.yaml" = {
            apiVersion = 1
            providers = [{
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }]
          }
        }

        # Community dashboard IDs from grafana.com
        dashboards = {
          default = {
            # Kubernetes cluster overview
            kubernetes-cluster = {
              gnetId     = 7249
              revision   = 1
              datasource = "Prometheus"
            }
            # Node metrics
            node-exporter = {
              gnetId     = 1860
              revision   = 31
              datasource = "Prometheus"
            }
            # Pod metrics
            kubernetes-pods = {
              gnetId     = 6417
              revision   = 1
              datasource = "Prometheus"
            }
          }
        }
      }

      # Prometheus configuration
      prometheus = {
        prometheusSpec = {
          # How long to keep metrics data
          retention = "7d"

          # Resource limits
          resources = {
            requests = {
              cpu    = "200m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }

      # AlertManager - disabled
      alertmanager = {
        enabled = false
      }
    })]
  }

  depends_on = [module.retail_app_eks]
}
