resource "aws_security_group" "test_rds_sg" {
  name = "test-rds-sg"
  vpc_id = var.vpc_id
  tags = {
  Name = "test-rds-sg"
  }
}


resource "aws_security_group_rule" "rds_ingress" { 
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"

  # cidr_blocks가 아니라 보안그룹 지정
  security_group_id = aws_security_group.test_rds_sg.id
  source_security_group_id = var.test_security_id
}

resource "aws_security_group_rule" "rds_egress"  {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_rds_sg.id
}

resource "aws_db_instance" "test_main" {
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "testdb"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.test_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.test_rds_sg.id]
}

resource "aws_db_subnet_group" "test_db_subnet_group" {
  name = "test-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "test-db-subnet-group"
  }
}





