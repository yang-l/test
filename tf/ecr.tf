resource "aws_ecr_repository" "main" {
  name = "${var.service_name}-app"
}
