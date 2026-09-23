module "eks" {
  source = "../../modules/eks"

  cluster_name = "${var.project_name}-${var.environment}"

  kubernetes_version = "1.35"

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets

  environment = var.environment

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
