variable "vpc_id" {
  type = string
}
#variable "subnet_id" {
#  type = string
#}

variable "instance_type" {
  type = string
}
# variable "ubuntu_ami" {
#  type = string
# }

variable "rds_address" {
  type = string
}

variable "test_alb_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}


