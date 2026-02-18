variable "vpc_id" {
  type = string
}

variable "test_security_id" {
  type = string
}

variable "db_username" {  
  type = string
}

variable "db_password" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}
