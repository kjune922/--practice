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
  # subnet_id = module.vpc.public_subnet_ids[0]
  instance_type = "t2.micro"
  ubuntu_ami = "ami-0dec6548c7c0d0a96"
  rds_address = module.rds.rds_instance_address
  test_alb_sg_id = module.alb.test_alb_sg_id
  private_subnet_ids = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]
  target_group_arn = module.alb.target_group_arn
}

# 3. rds모듈호출

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  db_username = "test"
  db_password = "dlrudalswns2!"
  private_subnet_ids = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]
  test_security_id = module.ec2.test_sg_id
}

# 4. alb모듈호출

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = [module.vpc.public_subnet_ids[0],module.vpc.public_subnet_ids[1]]
}



  





