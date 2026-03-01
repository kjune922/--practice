# 1. Github OIDC Identity Provider 설정
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Github Actions가 사용할 IAM role 생성
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role-${terraform.workspace}"

  # 이 롤은 내 깃허브 레포지토리에서만 가져갈수있게 제한
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:kjune922/*--practice*:*"
          }
        }
      }
    ]
  })
}

# 역할 생성
resource "aws_iam_role_policy_attachment" "github_admin" {
  role = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

