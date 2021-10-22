variable "vpc_id"{
    description = "VPC Id for Security Group"
    type=string
}
variable "subnet_id"{
    description = "Subnet Id for the ec2"
    type = string
}
variable "security_group_id"{
    description = "SG For reaching RDS"
    type = string
}
variable "aws_ec2_key_pair_public_key"{
    description = "SSH Public key"
    type = string
}
variable "aws_resource_suffix"{
    description = "Suffix to use on resource naming"
    type        = string
}