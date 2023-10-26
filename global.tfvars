environment  = "production"
bucket_name  = "clcm3102-group1-frontend"
service_name = "clcm3102-group1-dental-office"
public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjHqHuJUEXdgFDE4ivQt3ZA5bHYFfkIcdMlMqYIu8HM z.fu177@mybvc.ca"
additional_tags = {
  Environment   = "production"
  Administrator = "z.fu177@mybvc.ca"
  Terraform     = true
  Service       = "clcm3102-group1-dental-office"
}

vpc_id      = "vpc-551dcc28"
db_username = "dev1"
