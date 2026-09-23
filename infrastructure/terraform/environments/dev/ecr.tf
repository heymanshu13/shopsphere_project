module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name

  repositories = [
    "user-service",
    "product-service",
    "order-service",
    "payment-service",
    "notification-service"
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
