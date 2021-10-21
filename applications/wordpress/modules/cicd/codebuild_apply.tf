data "template_file" "buildspec_apply" {
  template = "${file("${path.module}/buildspec/terraform_apply.yml")}"
  vars = {
    env          = var.environment_shortname
  }
}

resource "aws_codebuild_project" "terraform_apply" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "wp-site-terraform-apply"
  queued_timeout = 480
  service_role   = aws_iam_role.build_role_apply.arn

  artifacts {
    encryption_disabled    = false
    name                   = "wp-site-${var.environment_shortname}"
    override_artifact_name = false 
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec_apply.rendered
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

resource "aws_iam_role" "build_role_apply" {
  name = "codebuild-${var.environment_shortname}-role-apply"

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

resource "aws_iam_role_policy" "build_role_apply" {
  role = aws_iam_role.build_role_apply.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}