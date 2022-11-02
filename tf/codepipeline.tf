resource "aws_iam_role" "codepipeline" {
  name = "${var.service_name}-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com",
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.service_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
      "Resource": "*",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecs:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.service_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        OAuthToken           = var.gh_oauth_token
        Owner                = var.gh_owner
        Repo                 = var.gh_repo
        Branch               = var.gh_branch
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }


  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "${var.service_name}-cp-s3-bucket"
}

resource "aws_s3_bucket_acl" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}
