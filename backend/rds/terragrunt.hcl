include "root" {
  path = find_in_parent_folders()
}

dependency "ec2" {
  config_path = "../ec2"
}

inputs = {
  source_security_group_id = dependency.ec2.outputs.security_group_id
}
