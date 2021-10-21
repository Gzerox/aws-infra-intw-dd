variable "repository_branch" {
  description = "Repository branch to connect to"
}

variable "repository_owner" {
  description = "GitHub repository owner"
}

variable "repository_name" {
  description = "GitHub repository name"
}

variable "environment_shortname" {
  description = "Short name form of the environment"
  type        = string
}
variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
}