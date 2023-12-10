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
