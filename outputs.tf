# ECR주소를 출력값으로 ㄱㄱ
output "ecr_repository_url" {
  value = aws_ecr_repository.test_app_repo.repository_url
}
