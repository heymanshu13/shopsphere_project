module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  database_password = var.database_password

  engine_version        = "16"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  database_name         = "shopsphere"
  database_username     = "shopsphere_admin"

  backup_retention_period = 0

  deletion_protection = false
  skip_final_snapshot = true
}
