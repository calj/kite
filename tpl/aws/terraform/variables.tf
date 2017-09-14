variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "public_key" {
  type = "string"
}

variable "private_key" {
  type = "string"
}

variable "keypair_name" {
  type = "string"
}

variable "region" {
  type = "string"
  default =  "eu-central-1"
}

variable "availability_zone" {
  type = "string"
  default =  "eu-central-1a"
}

variable "vpc_cidr_block" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "subnet_cidr" {
  type = "string"
}

variable "subnet_name" {
  type = "string"
}

variable "internal_gw" {
  type = "string"
}

variable "aws_amis" {
  default = {
    us-east-1 = "ami-1d4e7a66"
    eu-central-1 = "ami-958128fa"
  }
}
