terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.57.0"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}

resource "aws_key_pair" "webserver-key-pair" {
  key_name   = "webserver-key"
  public_key = file("./key.pub")
  tags = {
    "name"    = "webserver-key"
    "project" = "web-deploy"
  }
}

resource "aws_vpc" "webserver-vpc" {
  cidr_block = "172.20.0.0/16"
  tags = {
    "name"    = "webserver-vpc"
    "project" = "web-deploy"
  }
}


resource "aws_security_group" "sg-allow-web-ssh" {
  name        = "webserver_allow_web_ssh_sg"
  description = "Allow web and ssh inbound traffic"
  vpc_id      = aws_vpc.webserver-vpc.id

  tags = {
    "name"    = "webserver-sg"
    "project" = "web-deploy"
  }
}

resource "aws_security_group_rule" "ingress-rule-22" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-allow-web-ssh.id
}

resource "aws_security_group_rule" "ingress-rule-80" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-allow-web-ssh.id
}

resource "aws_security_group_rule" "egress-rule-all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-allow-web-ssh.id
}


resource "aws_subnet" "webserver_subnet" {
  vpc_id     = aws_vpc.webserver-vpc.id
  cidr_block = "172.20.10.0/24"

  tags = {
    "name"    = "webserver-subnet"
    "project" = "web-deploy"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.webserver-vpc.id

  tags = {
    Name      = "webserver-ig"
    "project" = "webserver"
  }
}

# resource "aws_route_table" "webserver-rt" {
#   vpc_id = aws_vpc.webserver-vpc.id
#   tags = {
#     Name      = "webserver-rt"
#     "project" = "webserver"
#   }
# }

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_vpc.webserver-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

output "Public-IP" {
  value = aws_instance.webserver.public_ip
}

resource "aws_instance" "webserver" {
  ami                         = "ami-087c17d1fe0178315"
  subnet_id                   = aws_subnet.webserver_subnet.id
  vpc_security_group_ids      = ["${aws_security_group.sg-allow-web-ssh.id}"]
  key_name                    = aws_key_pair.webserver-key-pair.key_name
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = <<EOT
    #!/usr/bin
    sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd 
    sudo iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
  EOT
  tags = {
    "name"    = "webserver-instance"
    "project" = "webserver"
  }
}