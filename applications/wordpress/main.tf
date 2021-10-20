module "network" {
  source = "./modules/network"
  aws_region = var.aws_region
  aws_availability_zones = var.aws_availability_zones
  aws_resource_suffix= "${var.project_name}-${var.environment_shortname}"
  aws_vpc_cidr_block=var.cidr_block
}

module "webserver" {
  source = "./modules/webserver"
  aws_resource_suffix = "${var.project_name}-${var.environment_shortname}"
  vpc_id = module.network.vpc_id
  subnets_ids = module.network.subnet_public_ids
  aws_ec2_key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlifHNJ2iRaIY1ECKjH2xqx3zuVs/Ec1gBKBFe1Iz4rPfc19KhFwimvJv1qC4tMCkYJizIRwa9my5oF5C6ErAhoUqKelNJWAHcmmOfMk0hec3AYZxCgq+nYhjS6gqVeWjYH/H0ZFtBMf6dLcxrDpNsdZ9jvBpn5DbooR38gqtQvFakIq8uSGOZiLpkJpT1qu95zE8hXTREqtUxDCi9ngKvjtMAgKwT7Ufjp/NJVm6k/wf3lzwTtfzpjFV8Ky+TaUfk7++n597s5KPOOXWQxB+02RM9sQamGQBwyuj8KzjvSYtDXY291GXkKDGR1LMjIrPloZo4p2OH5vXd7ajkSX9Kw== rsa-key-20211020"
}

# module "cicd" {
#   source = "./modules/cicd"
#   repository_branch = "develop"
#   repository_owner = "Gzerox"
#   repository_name = "aws-infra-intw-dd"
#   environment_shortname = var.environment_shortname
#   artifacts_bucket_name = "codepipeline-${var.project_name}-artifacts"
# }