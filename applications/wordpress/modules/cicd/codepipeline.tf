resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}
resource "aws_codepipeline" "static_web_pipeline" {
  name     = "static-web-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.repository_owner}/${var.repository_name}"
        BranchName       = var.repository_branch
      }
    }

  }
  stage {
    name = "Build"

    action {
      category = "Build"
      name = "TerraformPlan"
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"

      configuration = {
        EnvironmentVariables = jsonencode(
          [
            {
              name  = "ENV_NAME"
              type  = "PLAINTEXT"
              value = var.environment_shortname
            },
          ]
        )
        ProjectName = "wp-site-terraform-plan"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact",
      ]

    }
  }
  stage{
    name= "Approval"
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Build"
      configuration = {
        ProjectName = "wp-site-terraform-apply"
        EnvironmentVariables = jsonencode(
          [
            {
              name  = "ENV_NAME"
              type  = "PLAINTEXT"
              value = var.environment_shortname
            },
          ]
        )
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name             = "TerraformApply"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeBuild"
      run_order        = 1
      version          = "1"
    }
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.artifacts.arn}",
        "${aws_s3_bucket.artifacts.arn}/*"
      ]
    },
        {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.github.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}