module "eks" {
  source = "../../modules/eks"

  cluster_name = "${var.project_name}-${var.environment}"

  kubernetes_version = "1.35"

  vpc_id = module.vpc.vpc_id

  private_subnets = [
    "subnet-0248b004a9c0ca62f",
    "subnet-0812ae603023e204a"
  ]

  environment = var.environment

  enable_cloudwatch_monitoring = var.enable_cloudwatch_monitoring

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
