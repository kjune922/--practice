resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
  Name = "test_vpc-${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }

  tags = {
    Name = "public-route-table-test"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "private-route-table-test"
  }
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# NAT gateway가 사용할 고정 ip 생성
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = { Name = "test-nat-eip-${terraform.workspace}" }
}

# NAT gateway 선언

resource "aws_nat_gateway" "test_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet_1.id

  tags = { Name = "test-nat-gw-${terraform.workspace}" }
    
  depends_on = [aws_internet_gateway.igw]
}


# 프라이빗 라우팅 테이블 수정 (0.0.0.0/0이 NAT GW를 바라보게 ㄱㄱ)
resource "aws_route" "private_nat_route" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.test_nat_gw.id
}

