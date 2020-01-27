resource "aws_vpc" "reza_vpc" {
  cidr_block           = "10.15.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "reza_vpc"
  }
}

resource "aws_subnet" "prod_subnet_public_1a" {
  vpc_id                  = aws_vpc.reza_vpc.id
  cidr_block              = "10.15.1.0/24"
  map_public_ip_on_launch = "true"
  //it makes this a public subnet
  availability_zone = "us-east-1a"
  tags = {
    Name = "prod_subnet_public_1a"
  }
}

resource "aws_subnet" "prod_subnet_private_1a" {
    vpc_id = aws_vpc.reza_vpc.id
    cidr_block = "10.15.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-east-1a"
    tags = {
        Name = "prod_subnet_private_1a"
    }
}
