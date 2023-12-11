locals {
  log_group_name    = "/app/${var.environment}/dentalOffice"
  retention_in_days = 7
  metric_name       = "ErrorCount"
  namespace         = var.service_name
}

resource "aws_sns_topic" "error_topic" {
  name = "${var.service_name}-error-topic"
  tags = var.additional_tags
}

resource "aws_sns_topic_subscription" "admin_email" {
  topic_arn = aws_sns_topic.error_topic.arn
  protocol  = "email"
  endpoint  = var.additional_tags["Administrator"]
}

resource "aws_cloudwatch_log_group" "server_log" {
  name              = local.log_group_name
  retention_in_days = local.retention_in_days
  tags              = var.additional_tags
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.service_name}-error-filter"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.server_log.name

  metric_transformation {
    name      = local.metric_name
    namespace = local.namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_greater_than_5" {
  alarm_name                = "${var.service_name}-error-greater-than-5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = local.metric_name
  namespace                 = local.namespace
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 5
  alarm_description         = "This error metric monitors for ${var.service_name}"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.error_topic.arn]
  tags                      = var.additional_tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_greater_than_80" {
  alarm_name                = "${var.service_name}-memory-greater-than-80"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "MemoryUtilization"
  namespace                 = local.namespace
  period                    = 60
  statistic                 = "Average"
  threshold                 = 85
  alarm_description         = "This memory metric monitors for ${var.service_name}"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.error_topic.arn]
  tags                      = var.additional_tags
}


resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.service_name}-${var.environment}-alb-logs"
  tags   = var.additional_tags
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

## Alb logs

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}
