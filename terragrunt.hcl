locals {
  aws_region          = "us-east-1"
  env                 = "production"
  backend_bucket_name = "clcm3102-group-1-terraform-state"
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy", "import"]

    arguments = [
      "-var-file=${get_repo_root()}/global.tfvars"
    ]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = "${local.backend_bucket_name}"
    key     = "${local.env}/${path_relative_to_include()}/terraform.tfstate"
    region  = "${local.aws_region}"
    encrypt = true
  }
}
