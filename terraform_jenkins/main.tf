terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jenkins_master" {
  ami             = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t3.medium"
  key_name        = "portal_dev"
  security_groups = [aws_security_group.instances.name]
  tags = {
    Name = "Jenkins-Server"
  }
  user_data = <<-EOF
                     #!/bin/bash
                     apt-get update && apt-get install -y docker.io
                     systemctl start docker && systemctl enable docker
                     usermod -aG docker ubuntu

                     mkdir -p /jenkins_home
                     chown ubuntu /jenkins_home
                     docker run -d -p 8080:8080 -p 50000:50000 --name jenkins --restart=on-failure -v /jenkins_home:/var/jenkins_home jenkins/jenkins:lts
                     EOF
}

resource "aws_security_group" "instances" {
  name = "instance-security-group"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source            = "git::ssh://git@github.com/chicagopcdc/terraform_modules.git//aws/alb?ref=0.6.1"
  environment       = var.env_name
  app_name          = var.app_name
  vpc_id            = data.aws_vpc.vpc.id
  acm_cert_arn      = module.acm_cert.acm_cert_arn
  subnet_ids        = data.aws_subnets.public.ids
  security_group_id = aws_security_group.alb.id
  domain_url        = local.domain_url
  health_check_path = "/login?from=%2F"
}

resource "aws_security_group" "alb" {
  name   = "alb-group"
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn  = module.alb.alb_target_group_arn
  target_id         = aws_instance.jenkins_master.private_ip
  port              = 8080
  availability_zone = "us-east-1a"
}

# ACM cert
module "acm_cert" {
  source = "git::ssh://git@github.com/chicagopcdc/terraform_modules.git//aws/acm?ref=0.6.1"

  domain_url = local.domain_url
  app_name   = var.app_name
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "jenkins.${local.domain_url}"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}