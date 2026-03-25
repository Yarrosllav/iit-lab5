terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-north-1" 
}

resource "aws_security_group" "web_sg" {
  name        = "lab6_web_sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values =["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners =["099720109477"] # Canonical
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "lab4-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose
              systemctl start docker
              systemctl enable docker

              cat <<EOT > /home/ubuntu/docker-compose.yml
              version: '3.8'
              services:
                web:
                  image: yarrosllav/lab5-app:latest
                  ports:
                    - "80:80"
                  restart: always

                watchtower:
                  image: containrrr/watchtower
                  volumes:
                    - /var/run/docker.sock:/var/run/docker.sock
                  command: --interval 30
                  restart: always
              EOT

              cd /home/ubuntu
              docker-compose up -d
              EOF

  tags = {
    Name = "Lab6-Terraform-Instance"
  }
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}