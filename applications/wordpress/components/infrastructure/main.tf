module "network" {
  source = "../../modules/network"
  aws_region = var.aws_region
  aws_availability_zones = var.aws_availability_zones
  aws_resource_suffix= "${var.project_name}-${var.environment_shortname}"
  aws_vpc_cidr_block=var.cidr_block
}

module "webserver" {
  source = "../../modules/webserver"
  
  aws_s3_static_assets = "${var.project_name}-${var.environment_shortname}-static-assets"
  aws_resource_suffix = "${var.project_name}-${var.environment_shortname}"
  vpc_id = module.network.vpc_id
  lb_subnets_ids = module.network.subnet_public_ids
  private_subnets_ids = module.network.subnet_private_ids
  aws_ec2_key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlifHNJ2iRaIY1ECKjH2xqx3zuVs/Ec1gBKBFe1Iz4rPfc19KhFwimvJv1qC4tMCkYJizIRwa9my5oF5C6ErAhoUqKelNJWAHcmmOfMk0hec3AYZxCgq+nYhjS6gqVeWjYH/H0ZFtBMf6dLcxrDpNsdZ9jvBpn5DbooR38gqtQvFakIq8uSGOZiLpkJpT1qu95zE8hXTREqtUxDCi9ngKvjtMAgKwT7Ufjp/NJVm6k/wf3lzwTtfzpjFV8Ky+TaUfk7++n597s5KPOOXWQxB+02RM9sQamGQBwyuj8KzjvSYtDXY291GXkKDGR1LMjIrPloZo4p2OH5vXd7ajkSX9Kw== rsa-key-20211020"
}


module "rds"{
  source = "../../modules/rds"
  vpc_id = module.network.vpc_id
  aws_resource_suffix = "${var.project_name}-${var.environment_shortname}"
  aws_rds_az = var.aws_availability_zones
  rds_private_subnets_ids = module.network.subnet_private_ids
  security_group_id_allowed = [module.webserver.security_group_id]
}

/* module "bastionhost" {
  source = "../../modules/bastionhost"
  aws_resource_suffix = "${var.project_name}-${var.environment_shortname}"
  vpc_id=module.network.vpc_id
  subnet_id=module.network.subnet_public_ids[0]
  security_group_id=module.webserver.sg_rds.id
  aws_ec2_key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlifHNJ2iRaIY1ECKjH2xqx3zuVs/Ec1gBKBFe1Iz4rPfc19KhFwimvJv1qC4tMCkYJizIRwa9my5oF5C6ErAhoUqKelNJWAHcmmOfMk0hec3AYZxCgq+nYhjS6gqVeWjYH/H0ZFtBMf6dLcxrDpNsdZ9jvBpn5DbooR38gqtQvFakIq8uSGOZiLpkJpT1qu95zE8hXTREqtUxDCi9ngKvjtMAgKwT7Ufjp/NJVm6k/wf3lzwTtfzpjFV8Ky+TaUfk7++n597s5KPOOXWQxB+02RM9sQamGQBwyuj8KzjvSYtDXY291GXkKDGR1LMjIrPloZo4p2OH5vXd7ajkSX9Kw== rsa-key-20211020"
} */