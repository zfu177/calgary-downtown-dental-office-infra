include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_id = "vpc-0cfc992e72fac8cde"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "dental_office_development"
  db_username          = "postgres"
  db_subnet_group_name = "default-vpc-0cfc992e72fac8cde"
}