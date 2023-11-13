include "root" {
  path = find_in_parent_folders()
}

dependency "rds" {
  config_path = "../rds"
}

inputs = {
  security_group_id = dependency.rds.outputs.ec2_security_group_id
  db_url_ssm_parameter_arn = dependency.rds.outputs.db_url_ssm_parameter_arn
}
