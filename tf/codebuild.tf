data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###

resource "aws_iam_role" "codebuild" {
  name = "${var.service_name}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect":"Allow",
      "Resource": [
        "${aws_s3_bucket.codepipeline.arn}",
        "${aws_s3_bucket.codepipeline.arn}/*"
      ],
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.service_name}-project"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "REPO_NAME"
      value = aws_ecr_repository.main.name
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = "${var.service_name}-web"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.gh_owner}/${var.gh_repo}.git"
    git_clone_depth = 1
  }
}
