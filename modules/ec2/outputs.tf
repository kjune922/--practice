output "test_sg_id" {
  value = aws_security_group.test_sg.id
}

output "asg_name" {
  value = aws_autoscaling_group.test_asg.name
}


