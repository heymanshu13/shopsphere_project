resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = "${var.project_name}-${each.value}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = var.tags
}
