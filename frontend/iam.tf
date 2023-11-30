resource "aws_iam_policy" "s3_put_policy" {
  name        = "s3_put_policy"
  description = "Allows put objects into specific S3 bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.website.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "s3_put_user" {
  name = "${var.service_name}-s3-put"
  tags = var.additional_tags
}

resource "aws_iam_user_policy_attachment" "s3_put_user_policy_attachment" {
  user       = aws_iam_user.s3_put_user.name
  policy_arn = aws_iam_policy.s3_put_policy.arn
}

resource "aws_iam_access_key" "s3_put_user_key" {
  user = aws_iam_user.s3_put_user.name
}

resource "aws_ssm_parameter" "user_credentials" {
  name = "/iam/user/s3_put_user/credentials"
  type = "SecureString"
  value = jsonencode({
    access_key_id     = aws_iam_access_key.s3_put_user_key.id
    secret_access_key = aws_iam_access_key.s3_put_user_key.secret
  })

  tags = var.additional_tags
}
