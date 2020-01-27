//create internet gateway to make our vpc can connect to internet
resource "aws_internet_gateway" "reza_internetgateway" {
  vpc_id = aws_vpc.reza_vpc.id
  tags = {
    Name = "reza_internetgateway"
  }
}

//create aws eip
resource "aws_eip" "nat" {
  vpc      = true
  tags = {
      Name = "for nat gw"
  }
}

//create nat gw for private network to access internet
resource "aws_nat_gateway" "natgw" {
   // depends_on = ["aws_internet_gateway.reza_internetgateway.id"]
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.prod_subnet_public_1a.id
    tags = {
        Name = "reza_natgw"
    }
}

//create route table for public subnet
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.reza_vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.reza_internetgateway.id
  }

  tags = {
    Name = "rt_public"
  }
}
// create route table for private subnet
resource "aws_route_table" "rt_private"{
    vpc_id = aws_vpc.reza_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }

    tags = {
        Name = "rt_private"
    }

}
//create association between route table and public subnet
resource "aws_route_table_association" "prod_rt_public_subnet_1a" {
  subnet_id      = aws_subnet.prod_subnet_public_1a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "prod_rt_private_subnet_1a" {
    subnet_id = aws_subnet.prod_subnet_private_1a.id
    route_table_id = aws_route_table.rt_private.id
}

//create security group, to allow ssh access and http
resource "aws_security_group" "reza_sg" {
  vpc_id = aws_vpc.reza_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    // replace the cidr_blocks with your public IP address
    cidr_blocks = ["0.0.0.0/0"]
  }
  //allow us to access nginx 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["10.15.0.0/16"]
  }
  tags = {
    Name = "ssh-allowed"
  }
}