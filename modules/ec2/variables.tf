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
