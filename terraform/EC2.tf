
#Create public ec2
resource "aws_instance" "tf-public-ec2" {
    
    ami                     = var.ami
    instance_type           = "t2.micro"
    # VPC
    subnet_id               = module.network.subnet-public-tf-ID
    # Security Group
    vpc_security_group_ids  = [aws_security_group.tf-public-sg.id]
    # the Public SSH key
    key_name                = aws_key_pair.tfkeypair.key_name
  
    connection {
        user = "ubuntu"
        private_key = "${file("tfkey.pem")}"
    }

    tags = {
        Name = "tf-public-ec2"
    }
}

#Create private ec2
resource "aws_instance" "tf-private-ec2" {
    
    ami                     = "ami-053b0d53c279acc90"
    instance_type           = "t2.micro"
    # VPC
    subnet_id               = module.network.subnet-private-tf-ID
    # Security Group
    vpc_security_group_ids  = [aws_security_group.tf-private-sg.id]
    # the Public SSH key
    key_name                = aws_key_pair.tfkeypair.key_name
  
    connection {
        user = "ubuntu"
        private_key = "${file("tfkey.pem")}"
    }

    tags = {
        Name = "tf-private-ec2"
    }
}
