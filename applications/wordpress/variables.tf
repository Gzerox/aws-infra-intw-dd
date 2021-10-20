variable "cidr_block" {
  type = string
  default = "10.1.0.0/16"
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "wp-site"
}

variable "environment" {
  description = "Name of the environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "aws_availability_zones" {
  description = "AWS Region Availability Zones"
  type        = set(string)
}