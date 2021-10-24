variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "wp-site"
}
variable "environment" {
  description = "Name of the environment. (like: Development,Quality,Staging)"
  type        = string
}
variable "environment_shortname" {
  description = "Short name form of the environment (like:dev,qa,stg,prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}