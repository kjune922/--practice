resource "aws_lb" "test_alb" {
  name = "test-alb"
  internal = false # 외부 노출용이라는 뜻
  load_balancer_type = "application"
  security_groups = [aws_security_group.test_alb_sg.id]
  subnets = var.public_subnet_ids # ALB는 퍼블릭 서브넷에 있어야함

  tags = {
  Name = "test-alb"
  }
}

# 2. 대상 그룹(Target_group)

resource "aws_lb_target_group" "test_target" {
  name = "test-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.test_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test_target.arn
  }
}

# ALB전용 보안그룹


resource "aws_security_group" "test_alb_sg" {
  name = "test-alb-sg"
  vpc_id = var.vpc_id

  # 인바운드 -> 전세계에서 포트80으로 들어오는거 허용
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  Name = "test-alb-sg"
  }
}

resource "aws_lb_target_group_attachment" "test_attach" {
  target_group_arn = aws_lb_target_group.test_target.arn
  target_id = var.instance_id
  port = 80
}



















