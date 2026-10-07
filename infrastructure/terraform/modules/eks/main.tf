# --------------------------------------------------
# EBS CSI Driver IAM Role
# --------------------------------------------------

resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

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
    
      configuration_values = jsonencode({
        enableNetworkPolicy    = "true"
        enablePrefixDelegation = "true"
        warmPrefixTarget       = "1"
      })
    }

    kube-proxy = {
      most_recent = true
    }

    coredns = {
      most_recent = true
    }

    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }

    aws-ebs-csi-driver = {
      most_recent = true

      pod_identity_association = [
        {
          role_arn        = aws_iam_role.ebs_csi_driver.arn
          service_account = "ebs-csi-controller-sa"
        }
      ]
    }
  }


  # --------------------------------------------------
  # EKS Managed Node Group
  # --------------------------------------------------

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
    }
  }


  # --------------------------------------------------
  # Tags
  # --------------------------------------------------

  tags = var.tags
}
