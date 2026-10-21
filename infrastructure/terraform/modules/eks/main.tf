# EKS Cluster

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  enabled_log_types = var.enable_cloudwatch_monitoring ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ] : []

  create_cloudwatch_log_group = var.enable_cloudwatch_monitoring

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  access_entries = {
    shopsphere_admin = {
      principal_arn = "arn:aws:iam::278177224853:user/ShopSphere"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  addons = merge(
    {
      vpc-cni = {
        addon_version  = "v1.23.2-eksbuild.1"
        before_compute = true

        configuration_values = jsonencode({
          enableNetworkPolicy = "true"
        })
      }

      kube-proxy = {
        addon_version = "v1.35.3-eksbuild.49"
      }

      coredns = {
        addon_version = "v1.14.7-eksbuild.11"
      }
    },
    var.enable_cloudwatch_monitoring ? {
      amazon-cloudwatch-observability = {
        most_recent = true
        preserve    = false
      }
    } : {}
  )

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 4
      desired_size = 4

      capacity_type = "ON_DEMAND"

      labels = {
        Environment = var.environment
      }

      iam_role_additional_policies = var.enable_cloudwatch_monitoring ? {
        CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
        AWSXrayWriteOnlyAccess      = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
      } : {}
    }
  }

  tags = var.tags
}
