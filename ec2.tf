# configured aws provider with proper credentials

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-ecs"
}


# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket  = "o3cloudng-terraform-state-bucket-1"
    key     = "build/terraform.tfstate"
    region  = "us-east-1"
    profile = "terraform-ecs"
  }
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags = {
    Name = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "sonar_security_group" {
  name        = "SG Sonarqube"
  description = "allow access on ports 9000 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http access 9000 for sonarqube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "http access 8080 for Jenkins"
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonar security group"
  }
}


# use data source to get a registered amazon linux 2 ami
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "owner-alias"
#     values = ["amazon"]
#   }

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

# data "aws_ami" "ubuntu" {
#     most_recent = true

#     filter {
#         name   = "name"
#         values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
#     }

#     filter {
#         name   = "virtualization-type"
#         values = ["hvm"]
#     }

#     owners = ["099720109477"] # Canonical
# }
data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
 
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-*"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu-linux-2004.id
  instance_type          = "t2.medium"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.sonar_security_group.id]
  key_name               = "terraform-key-pair"
  user_data              = "${file("install_sonarqube.sh")}"

  tags = {
    Name = "Sonarqube server"
  }
}


# print the url of the server
output "ec2_public_ipv4_url" {
  value = join("", ["http://", aws_instance.ec2_instance.public_ip, ":9000"])
}