terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.1"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "testvpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = "true"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

#Security Group 
resource "aws_security_group" "ssh-allowed" {
    name = "ssh group"
    vpc_id =  aws_vpc.main.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-allowed"
    }
}


##Instance 

resource "aws_instance" "instance" {
  availability_zone = "eu-north-1a"
  instance_type = "t3.micro"
  ami = "ami-01a7573bb17a45f12"
  monitoring = true
  key_name = "test"
  subnet_id = "${aws_subnet.main.id}"
  vpc_security_group_ids = [ "${aws_security_group.ssh-allowed.id}" ]

  tags = {
    Name = "Testvm"
  }
  
}
