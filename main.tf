terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.52.0"
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

# setup a VPCs
module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  name                  = "${var.common_name}-vpc"
  cidr                  = var.aws_vpc_primary_cidr_block
  secondary_cidr_blocks = [var.aws_vpc_secondary_cidr_block, var.aws_vpc_tertiary_cidr_block]
  azs                   = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets       = ["10.0.1.0/24", "10.1.2.0/24", "10.2.3.0/24"]
  public_subnets        = ["10.0.101.0/24", "10.1.102.0/24", "10.2.103.0/24"]
  public_subnet_tags = {
    Name = "overridden-name-public"
  }
  tags = {
    Terraform   = "true"
    CreatedDate = timestamp()
  }
  vpc_tags = {
    Name = "${var.common_name}-vpc"
  }
}

module "router_sg" {
  depends_on          = [module.vpc]
  source              = "terraform-aws-modules/security-group/aws"
  name                = "${var.common_name}-sg"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  tags = {
    Terraform   = "true"
    CreatedDate = timestamp()
  }
}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${var.common_name}-key"
  public_key = ""
}

data "template_file" "script" {
  template = file("${path.module}/config/cloud_init/vyos/simple.cfg")
  #   vars = {
  #     bgp_local_asn               = var.bgp_local_asn
  #     bgp_neighbor_asn            = var.bgp_neighbor_asn
  #     bgp_password                = random_string.bgp_password.result
  #     hostname                    = var.hostname
  #     ipsec_psk                   = random_string.ipsec_psk.result
  #     ipsec_peer_public_ip        = var.ipsec_peer_public_ip
  #     ipsec_peer_private_ip       = cidrhost(var.ipsec_private_cidr, 2)
  #     ipsec_private_ip_cidr       = format("%s/%s", cidrhost(var.ipsec_private_cidr, 2), split("/", var.ipsec_private_cidr)[1])
  #     neighbor_short_name         = var.neighbor_short_name
  #     private_net_cidr            = var.private_net_cidr
  #     private_net_dhcp_start_ip   = cidrhost(var.private_net_cidr, 2)
  #     private_net_dhcp_stop_ip    = cidrhost(var.private_net_cidr, -2)
  #     private_net_gateway_ip_cidr = format("%s/%s", cidrhost(var.aws_vpc_secondary_cidr_block, 1), split("/", var.aws_vpc_secondary_cidr_block)[1])
  #     private_net_gateway_ip      = cidrhost(var.private_net_cidr, 2)
  #     public_dns_1_ip             = var.public_dns_1_ip
  #     public_dns_2_ip             = var.public_dns_2_ip
  #     router_ipv6_gateway_ip      = packet_device.router.network.1.gateway
  #     router_ipv6_ip_cidr         = format("%s/%s", packet_device.router.network.1.address, packet_device.router.network.1.cidr)
  #     router_private_cidr         = format("%s/%s", cidrhost(format("%s/%s", packet_device.router.network.2.address, packet_device.router.network.2.cidr), 0), packet_device.router.network.2.cidr)
  #     router_private_gateway_ip   = packet_device.router.network.2.gateway
  #     router_private_ip_cidr      = format("%s/%s", packet_device.router.network.2.address, packet_device.router.network.2.cidr)
  #     router_public_gateway_ip    = packet_device.router.network.0.gateway
  #     router_public_ip_cidr       = format("%s/%s", packet_device.router.network.0.address, packet_device.router.network.0.cidr)
  #     router_public_ip            = packet_device.router.network.0.address
  #   }
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}

module "vyos_instances" {
  depends_on             = [module.router_sg]
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "2.19.0"
  name                   = "${var.common_name}-vyos"
  instance_count         = 1
  ami                    = lookup(var.aws_vyos_amis, var.aws_region)
  instance_type          = var.aws_vyos_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id, module.router_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = module.key_pair.key_pair_key_name

  # commands to test userdata
  # https://docs.vyos.io/en/latest/automation/cloud-init.html
  user_data_base64 = data.template_cloudinit_config.config.rendered
  tags = {
    Terraform   = "true"
    CreatedDate = timestamp()
  }
}
module "ubuntu_instances" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "2.19.0"
  name                   = "${var.common_name}-ubuntu-test"
  instance_count         = 2
  ami                    = lookup(var.aws_ubuntu_amis, var.aws_region)
  instance_type          = var.aws_ubuntu_instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = module.key_pair.key_pair_key_name
  tags = {
    Terraform   = "true"
    CreatedDate = timestamp()
  }
}
