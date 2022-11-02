resource "aws_ecr_repository" "ecr" {
  name = "${var.service_name}-ecr"
}
