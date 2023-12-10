output "website_domain" {
  value = aws_s3_bucket_website_configuration.website.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "bucket_name" {
  value = aws_s3_bucket.website.id
}

output "s3_put_credential_name" {
  value = aws_ssm_parameter.user_credentials.name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web.name
}
