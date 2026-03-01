resource "aws_cloudwatch_dashboard" "main" { 
  dashboard_name = "kjune922-infra-dashboard-${terraform.workspace}"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${module.ec2.asg_name}" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "ap-northeast-2",
        "title": "EC2 CPU Utilization"
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic" "test_user_update" {
  name = "test-infra-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.test_user_update.arn
  protocol = "email"
  endpoint = "dlrudalswns2@gmail.com"
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "High-CPU-Usage-${terraform.workspace}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" # 1분 동안
  statistic           = "Average"
  threshold           = "80" # 80% 이상이면

  dimensions = {
    AutoScalingGroupName = module.ec2.asg_name
  }

  alarm_description = "이 알람은 CPU 사용량이 80%를 넘으면 울립니다."
  alarm_actions     = [aws_sns_topic.test_user_update.arn]
}
