resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  authentication  = "GITHUB_HMAC"
  name            = "codepipeline-webhook"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.static_web_pipeline.name

  authentication_configuration {
    secret_token = random_string.github_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
  tags = {}
}

resource "random_string" "github_secret" {
  length  = 99
  special = false
}