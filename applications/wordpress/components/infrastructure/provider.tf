terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
  }
  # On first terraform apply,  you should comment out this.
  backend "s3" {
    key    = "infrastructure/terraform_tfstate"
  }
  required_version = ">= 1.0.9"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = "DevOps Team"
    }
  }
}