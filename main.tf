provider "aws" {
  region = "ap-northeast-2"
}

# 1. vpc모듈호출

module "vpc" {
  source = "./modules/vpc"
}

# 2. ec2모듈호출

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  instance_type = "t2.micro"
  ubuntu_ami = "ami-0dec6548c7c0d0a96"
}




