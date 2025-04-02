// main.tf

provider "aws" {
    region = "sa-east-1"
    
}

variable "server_port"{
    description= "Porta de Serviço Web"
    type = number
    default = 80

}

resource "aws_instance" "exemple_server" {
  ami           = "ami-0d866da98d63e2b42"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  user_data = <<-EOF
  #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo Hello World > run on port ${var.server_port}>/var/www/html/index.html'
              EOF
  
  user_data_replace_on_change = true

  tags = {
    Name= "Ubuntu_server"
  }

}

resource "aws_security_group" "instance" {
	name = "Ubuntu_server_Node1"

	//porta de entrada
	  ingress { 
		from_port = var.server_port
		to_port = var.server_port
		protocol = "tcp"
  	cidr_blocks = ["0.0.0.0/0"]
	}
  
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
  }
  
}

output "public_ip" {
  value = aws_instance.exemple_server.public_ip
  description = "Ip Publico da Instancia EC2"
  
}


    
