variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
}
variable "ubuntu_ami" {
  type = string
}

variable "rds_address" {
  type = string
}

variable "test_alb_sg_id" {
  type = string
}

