variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "aws_vpc_cidr_block"{
    description = "CIDR Block to use as VPC"
    type        = string
}
variable "aws_resource_suffix"{
    description = "Suffix to use on resource naming"
    type        = string
}
variable "aws_availability_zones" {
  description = "AWS Region Availability Zones"
  type        = set(string)
}
