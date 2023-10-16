include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "ec2" {
  config_path = "../ec2"
}

inputs = {
  source_security_group_id = dependency.ec2.outputs.security_group_id
  private_subnet_ids = dependency.vpc.outputs.database_subnet_ids
  vpc_id = dependency.vpc.outputs.vpc_id
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
}
