variable "vpc_id"{
    description = "VPC Id for the security group of RDS Instances"
    type        = string
}
variable "security_group_id_allowed"{
    description = "Security Group ID Allowed to connect to RDS Instances"
    type        = set(string)
}
variable "aws_resource_suffix"{
    description = "Suffix to use on resource naming"
    type        = string
}
variable "aws_rds_az" {
    description = "AZ for RDS Cluster"
    type        = set(string)
}
variable "rds_private_subnets_ids" {
    description = "Subnets id in which RDS Instance can be located"
    type = set(string)
}