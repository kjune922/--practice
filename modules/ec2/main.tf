# 일단 ec2부터 해보자

resource "aws_instance" "test_app" {
  ami = var.ubuntu_ami
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  key_name = "test"
  associate_public_ip_address = true

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/userdata.sh",{db_endpoint = var.rds_address})

  tags = {
  Name = "test-ec2"
  }
}

resource "aws_security_group" "test_sg"{
  name = "test-sg"
  vpc_id = var.vpc_id

  ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_groups = [var.test_alb_sg_id] # 이제 모든 주소범위는 보안그룹id로 바뀌면서, alb한테 받아함야
  }

  ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # 내가 직접 접속하는 ssh니까 이건 고
  }

  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
  Name = "test-sg"
  }
}



