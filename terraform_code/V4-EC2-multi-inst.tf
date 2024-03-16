provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-023c11a32b0207432"
    instance_type = "t2.micro"
    key_name = "prachi-practice"
   // security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.dpw-public-subnet01.id
    for_each = toset(["Jenkins-master","Build-slave","Ansible"])
    tags = {
      Name = "${each.key}"
    }
    
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.dpw-vpc.id
  
  ingress {
    description      = "SHH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "Jenkins access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}
resource "aws_vpc" "dpw-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "dpw-vpc"

    }
}
resource "aws_subnet" "dpw-public-subnet01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "dpw-public-subnet01"
    }
  
}
resource "aws_subnet" "dpw-public-subnet02" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "dpw-public-subnet02"
    }  
}
resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id
    tags = {
      Name = "dpw-igw"
    }
}
resource "aws_route_table" "dpw-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }  
}  
resource "aws_route_table_association""dpw-rt-ass-subnet01"{
    subnet_id = aws_subnet.dpw-public-subnet01.id
    route_table_id = aws_route_table.dpw-rt.id
}
resource "aws_route_table_association""dpw-rt-ass-subnet02"{
    subnet_id = aws_subnet.dpw-public-subnet02.id
    route_table_id = aws_route_table.dpw-rt.id
}
