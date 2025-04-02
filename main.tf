provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
    description = "Porta de Serviço Web"
    type        = number
    default     = 80
}

resource "aws_launch_template" "ubuntu_server" {
  name          = "ubuntu-launch-template"
  image_id      = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  
  network_interfaces {
    security_groups = [aws_security_group.instance.id]
  }
  
  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo systemctl start apache2
  echo "Hello World - run on port ${var.server_port}" | sudo tee /var/www/html/index.html
  EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Ubuntu-Server"
    }
  }
}

# Obtendo a VPC padrão
data "aws_vpc" "default" {
  default = true
}

# Obtendo as subnets da VPC padrão
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_autoscaling_group" "ubuntu_server" {
  min_size            = 2
  max_size            = 3
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.ubuntu_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "ubuntu_server_nodes"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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
