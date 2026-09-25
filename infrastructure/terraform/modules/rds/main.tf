resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.environment}-rds"
  description = "Allow PostgreSQL access from ShopSphere EKS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  publicly_accessible = false

  backup_retention_period = var.backup_retention_period

  backup_window      = "18:00-19:00"
  maintenance_window = "sun:19:00-sun:20:00"

  auto_minor_version_upgrade = true

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  copy_tags_to_snapshot = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}
