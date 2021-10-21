terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
  }
  required_version = ">= 1.0.9"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      Owner       = "DevOps Team"
    }
  }
}

resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "${var.project_name}-${var.environment_shortname}-tfstate"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tf_remote_state_locking" {
  hash_key = "LockID"
  name = "${var.project_name}-terraform-${var.environment_shortname}-locking"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}