output "test_alb_sg_id" {
  value = aws_security_group.test_alb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.test_target.arn
}

