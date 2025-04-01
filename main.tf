// main.tf

provider "aws" {
    region = "sa-east-1"
    
}

resource "aws_instance" "exemple_server" {
  ami           = "ami-0d866da98d63e2b42"
  instance_type = "t2.micro"

  tags = {
    Name= "Ubuntu_server"
  }

}


    
