variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "wp-site"
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "environment" {
  description = "Name of the environment."
  type        = string
}
variable "environment_shortname" {
  description = "Short name form of the environment"
  type        = string
}