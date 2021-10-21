variable "vpc_id" {
  type = string
}
variable "aws_resource_suffix"{
    description = "Suffix to use on resource naming"
    type        = string
}
variable "aws_ec2_key_pair_public_key" {
    description = "Public Key for accessing EC2 instance via SSH"
    type = string
}
variable "lb_subnets_ids" {
    description = "List of subnets ids to be used for LB."
    type = set(string)
}
variable "private_subnets_ids" {
    description = "List of subnets ids to be used withing the autoscaling group."
    type = set(string)
}