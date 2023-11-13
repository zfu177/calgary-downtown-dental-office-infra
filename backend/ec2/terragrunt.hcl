include "root" {
  path = find_in_parent_folders()
}

dependency "rds" {
  config_path = "../rds"
}

inputs = {
  security_group_id = dependency.rds.outputs.ec2_security_group_id
  db_url_ssm_parameter_arn = dependency.rds.outputs.db_url_ssm_parameter_arn
  
  instance_type = "t2.micro"
  instance_profile_name = "LabInstanceProfile"
  document_name = "update-code"
  key_name = "admin-key"
  public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjHqHuJUEXdgFDE4ivQt3ZA5bHYFfkIcdMlMqYIu8HM z.fu177@mybvc.ca"
}
