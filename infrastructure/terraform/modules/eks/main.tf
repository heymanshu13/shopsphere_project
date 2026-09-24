module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  # --------------------------------------------------
  # EKS Access Entries
  # --------------------------------------------------
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

  # --------------------------------------------------
  # EKS Managed Add-ons
  # --------------------------------------------------
  addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }

    kube-proxy = {
      most_recent = true
    }

    coredns = {
      most_recent = true
    }
  }

  # --------------------------------------------------
  # EKS Managed Node Group
  # --------------------------------------------------
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      capacity_type = "ON_DEMAND"

      labels = {
        Environment = var.environment
      }
    }
  }

  # --------------------------------------------------
  # Tags
  # --------------------------------------------------
  tags = var.tags
}
