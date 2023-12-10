resource "aws_ssm_document" "update_code" {
  name          = var.document_name
  document_type = "Command"

  content = <<DOC
{
  "schemaVersion" : "2.2",
  "description" : "Update code repo",
  "mainSteps" : [ {
    "action" : "aws:runShellScript",
    "name" : "update",
    "inputs" : {
      "runCommand" : [
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && git pull'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && sed -i \"s/RUBY_VERSION=.*/RUBY_VERSION=3.0.6/g\" Dockerfile'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && sed -i \"s/config.force_ssl =.*/config.force_ssl = false/g\" ./config/environments/production.rb'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && docker compose build'",
        "systemctl restart dentaloffice"
        ]
    }
  } ]
}
DOC

  tags = var.additional_tags
}

resource "aws_iam_user" "ssm_user" {
  name = "${var.service_name}-run-document"
  tags = var.additional_tags
}

resource "aws_iam_access_key" "ssm_user_key" {
  user = aws_iam_user.ssm_user.name
}

resource "aws_ssm_parameter" "user_credentials" {
  name = "/iam/user/ssm_run_document/credentials"
  type = "SecureString"
  value = jsonencode({
    access_key_id     = aws_iam_access_key.ssm_user_key.id
    secret_access_key = aws_iam_access_key.ssm_user_key.secret
  })
  tags = var.additional_tags
}

resource "aws_iam_policy" "ssm_execute_policy" {
  name        = "ssm_execute_policy"
  description = "Allows execution of SSM document"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:SendCommand",
      "Resource": "${aws_ssm_document.update_code.arn}"
    },
    {
      "Effect":"Allow",
      "Action":[
        "ssm:SendCommand"
      ],
      "Resource":[
        "arn:aws:ec2:*:*:instance/*"
      ],
      "Condition":{
        "StringLike":{
            "ssm:resourceTag/Service":[
              "${var.service_name}"
            ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:DescribeAutoScalingGroups",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ssm:GetCommandInvocation",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "ssm_execute_policy_attachment" {
  user       = aws_iam_user.ssm_user.name
  policy_arn = aws_iam_policy.ssm_execute_policy.arn
}
