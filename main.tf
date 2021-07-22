terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.50.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "2.4.1"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
