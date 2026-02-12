# 생성된 public ip 출력
output "instance_public_ip" {
  value = aws_instance.test_app.public_ip
}

# 인스턴스 상태 호출
output "instance_state" {
  value = aws_instance.test_app.instance_state
}

