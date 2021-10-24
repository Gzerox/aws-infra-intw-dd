module "cicd" {
  source = "../../modules/cicd"
  repository_branch = "develop"
  repository_owner = "Gzerox"
  repository_name = "aws-infra-intw-dd"
  environment_shortname = var.environment_shortname
  artifacts_bucket_name = "codepipeline-${var.project_name}-artifacts"
  tfstate_bucket_name = "${var.project_name}-${var.environment_shortname}-tfstate"
}