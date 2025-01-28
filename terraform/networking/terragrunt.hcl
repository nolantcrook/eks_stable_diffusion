include "env" {
  path = "${get_repo_root()}/environments/${get_env("ENV", "dev")}/terragrunt.hcl"
}

dependency "foundation" {
  config_path = "../foundation"
}

inputs = {
  environment = get_env("ENV", "dev")
  route53_zone_id_secret_arn = dependency.foundation.outputs.route53_zone_id_secret_arn
  single_az_dev = true
  create_multi_az_alb = get_env("ENV", "dev") == "prod"  # Only true in prod
} 