include "root" {
  path = find_in_parent_folders()
}

dependency "rds" {
  config_path = "../rds"
}

inputs = {
  rds_security_group_id = dependency.rds.outputs.rds_security_group_id
  db_url_ssm_parameter_arn = dependency.rds.outputs.db_url_ssm_parameter_arn
  db_url_ssm_parameter_name = dependency.rds.outputs.db_url_ssm_parameter_name
  
  vpc_id = "vpc-551dcc28"
  instance_type = "t2.micro"
  instance_profile_name = ""
  document_name = "update-code"
  key_name = "admin-key"
  public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjHqHuJUEXdgFDE4ivQt3ZA5bHYFfkIcdMlMqYIu8HM z.fu177@mybvc.ca"
  admin_email = "z.fu177@mybvc.ca"
  public_subnet_ids = ["subnet-e91246a4", "subnet-5736b008", "subnet-2bd0af25", "subnet-6f6aef09"]
}
