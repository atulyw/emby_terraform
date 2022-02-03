provider "aws" {
  region  = "ap-south-1"
  profile = "emby_ec2"
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = "emby-server"
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  monitoring             = false
  vpc_security_group_ids = [module.emby_service_sg.security_group_id]
  subnet_id              = var.subnet_id
  user_data              = local.userdata

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_caller_identity" "current" {}


module "emby_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "user-service"
  description        = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id             = var.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8096
      to_port     = 8096
      protocol    = "tcp"
      description = "emby ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "emby ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_eip" "this" {
  instance = module.ec2_instance.id
  vpc      = true
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "emby-key"
  public_key = tls_private_key.example.public_key_openssh
}

output "public_ip" {
  value = aws_eip.this.public_ip
}