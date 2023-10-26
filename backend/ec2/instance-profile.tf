resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.service_name}-instance-profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "ec2" {
  name   = "${var.service_name}-ec2-custom-policy"
  role   = aws_iam_role.role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:GetParametersByPath"
      ],
      "Effect": "Allow",
      "Resource": "${var.db_credential_ssm_parameter_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "role" {
  name                = "${var.service_name}-role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}
