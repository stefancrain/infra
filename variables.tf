variable "common_name" {
  description = "The common environment name to use for most resources."
  default     = "Router"
}
variable "aws_region" {
  description = "The region to provision AWS resources in."
  default     = "us-west-2"
}

locals {
  db_creds = yamldecode(sops_decrypt_file(("secrets/db-creds.yml")))
}

variable "aws_vpc_primary_cidr_block" {
  description = "First CIDR block to use for the AWS VPC."
  default     = "10.0.0.0/16"
}
variable "aws_vpc_secondary_cidr_block" {
  description = "Second CIDR block to use for the AWS VPC."
  default     = "10.1.0.0/16"
}
variable "aws_vpc_tertiary_cidr_block" {
  description = "Third CIDR block to use for the AWS VPC."
  default     = "10.2.0.0/16"
}
variable "aws_vpc_cidr_public_subnets" {
  description = "The public subnet CIDR blocks"
  default     = ["10.1.1.0/24"]
}
variable "aws_vpc_primary_cidr_private_subnets" {
  description = "The public subnet CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "aws_vpc_secondary_cidr_private_subnets" {
  description = "The public subnet CIDR blocks"
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}
variable "aws_vpc_tertiary_cidr_private_subnets" {
  description = "The public subnet CIDR blocks"
  default     = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
}
variable "aws_vyos_amis" {
  description = "VyOS on AWS (Standard Support) - Pay-as-You-Go [1.2.x (HVM) with EBS Volume.]"
  type        = map
  default = {
    "eu-north-1"     = "ami-055ce8ee0ef3c61fd"
    "ap-south-1"     = "ami-008114291e94efc69"
    "eu-west-3"      = "ami-0cd44859514ef6f2d"
    "eu-west-2"      = "ami-0afd1afd7cc2b8e2b"
    "eu-west-1"      = "ami-065486639b81f9b0f"
    "ap-northeast-3" = "ami-05290bbe03dccf141"
    "ap-northeast-2" = "ami-07544c98ec0e9c886"
    "ap-northeast-1" = "ami-08405c868575892d3"
    "sa-east-1"      = "ami-09715728a86813f19"
    "ca-central-1"   = "ami-0fe2b953337aef86a"
    "ap-southeast-1" = "ami-0eadb12406f6e5fad"
    "ap-southeast-2" = "ami-0443dfdb159165f52"
    "eu-central-1"   = "ami-0788ed084b54d6dd1"
    "us-east-1"      = "ami-0fa0d75bcdae6b2c8"
    "us-east-2"      = "ami-0e67cee8012250e52"
    "us-west-1"      = "ami-0695b15de12a64230"
    "us-west-2"      = "ami-02794410da81bdaca"
  }
}
variable "aws_ubuntu_amis" {
  description = "Linux/Unix, Ubuntu 20.04 - Focal | 64-bit (x86) Amazon Machine Image (AMI)"
  type        = map
  default = {
    "eu-north-1"     = "ami-00888f2a5f9be4390"
    "ap-south-1"     = "ami-0443fb07ed652c341"
    "eu-west-3"      = "ami-06d3fffafe8d48b35"
    "eu-west-2"      = "ami-0230a6736b38ae83e"
    "eu-west-1"      = "ami-0298c9e0d2c86b0ed"
    "ap-northeast-3" = "ami-01ae085ceefba2dbf"
    "ap-northeast-2" = "ami-0f49ee52a88cc2435"
    "ap-northeast-1" = "ami-0b0ccc06abc611fa0"
    "sa-east-1"      = "ami-04e56ee48b28650b3"
    "ca-central-1"   = "ami-04673916e7c7aa985"
    "ap-southeast-1" = "ami-0f0b17182b1d50c14"
    "ap-southeast-2" = "ami-04b1878ebf78f7370"
    "eu-central-1"   = "ami-05e1e66d082e56118"
    "us-east-1"      = "ami-019212a8baeffb0fa"
    "us-east-2"      = "ami-0117d177e96a8481c"
    "us-west-1"      = "ami-0b08e71a81ba4200f"
    "us-west-2"      = "ami-02868af3c3df4b3aa"
  }
}
# VyOS requires a medium or larger
variable "aws_vyos_instance_type" {
  description = "VYOS router AWS instance type to launch."
  default     = "t3.medium"
}
# The test images can be whatever we want
variable "aws_ubuntu_instance_type" {
  description = "Ubuntu AWS instance type to launch."
  default     = "t3.nano"
}
resource "random_string" "bgp_password" {
  length      = 18
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}
resource "random_string" "ipsec_psk" {
  length      = 32
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  special     = false
}
