# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "dedicated"
  enable_dns_hostnames = true
  

  tags = {
    Name = "Test VPC"
  }
}

#Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = " Test aws_internet_gateway "
  }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet-1-cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet 1"
  }
}


# Create Public Subnet 2
# terraform aws create subnet
#resource "aws_subnet" "public-subnet-2" {
#  vpc_id                  = aws_vpc.vpc.id
 # cidr_block              = var.public-subnet-2-cidr
  #availability_zone       = "us-east-2b"
  #map_public_ip_on_launch = true

  #tags = {
  #  Name = "Public subnet 2"
  #}
#}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Public route table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

# Associate Public Subnet 2 to "Public Route Table"
# terraform aws associate subnet with route table
#resource "aws_route_table_association" "public-subnet-2-route-table-association" {
#  subnet_id      = aws_subnet.public-subnet-2.id
#  route_table_id = aws_route_table.public-route-table.id
#}

# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet-1-cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnet 1"

  }
}

# now we are creating SECURITY GROUP
# with DYNAMIC BLOCK

resource "aws_security_group" "terraform_security" {
  name        = "terraform_security"
  description = "Allow ssh and http inboubd trafic"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

# Creating instance !!!


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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "my-instance" {

  count = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id      = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.terraform_security.name]


  user_data = <<EOF
#! /bin/bash
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2
echo "dhiraj here" > /var/www/html/index.html
sudo systemctl restart apache2
EOF

  tags = var.tags

}

 