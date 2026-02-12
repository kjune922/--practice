# ouputs은 다른 모듈에서 이 VPC를 찾을 수 있게 id를 내보내는 역할
output "vpc_id" { 
  value = aws_vpc.test_vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id]
}


