resource "aws_cloudwatch_log_group" "app" {
  name              = "/fintech/app"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_actions       = []
}
