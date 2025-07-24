data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["pcdc-${var.env_name}"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_route53_zone" "zone" {
  name         = local.domain_url
  private_zone = false
}