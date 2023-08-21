# AWS
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "tf-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    #enable_classiclink = "true"
    instance_tenancy = "default"    
    
    tags = {
        Name = "tf-vpc"
    }
}

# Create Public subnet
resource "aws_subnet" "subnet-public-tf" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-east-1a"
    tags = {
        Name = "subnet-public-tf"
    }
}

# Create private subnet
resource "aws_subnet" "subnet-private-tf" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "false" //it makes this a private subnet
    availability_zone = "us-east-1b"
    tags = {
        Name = "subnet-private-tf"
    }
}

# Create Internet gateway and attach it to the VPC
resource "aws_internet_gateway" "tf-igw" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    tags = {
        Name = "tf-igw"
    }
}

# Create Route Tables
resource "aws_route_table" "tf-public-rt" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.tf-igw.id}" 
    }

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    
    tags = {
        Name = "tf-public-rt"
    }
}

resource "aws_route_table_association" "tf-rta-public-subnet"{
    subnet_id = "${aws_subnet.subnet-public-tf.id}"
    route_table_id = "${aws_route_table.tf-public-rt.id}"
}

resource "aws_route_table" "tf-private-rt" {
    vpc_id = "${aws_vpc.tf-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.tf-NatGateway.id}"
    } 
    tags = {
        Name = "tf-private-rt"
    }
}

resource "aws_route_table_association" "tf-rta-private-subnet"{
    subnet_id = "${aws_subnet.subnet-private-tf.id}"
    route_table_id = "${aws_route_table.tf-private-rt.id}"
}

#Create public security group
resource "aws_security_group" "tf-public-sg" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1 //All traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "tf-public-sg"
    }
}

#Create private security group
resource "aws_security_group" "tf-private-sg" {
    vpc_id = "${aws_vpc.tf-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1 //All traffic
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 65535  # All TCP ports
        protocol    = "tcp"
        cidr_blocks = ["10.0.3.0/24"]  
    }

    ingress {
        from_port   = 0
        to_port     = 65535  # All TCP ports
        protocol    = "tcp"
        security_groups = [aws_security_group.tf-public-sg.id]
    }

    # ingress {
    #     from_port = 22
    #     to_port = 22
    #     protocol = "tcp"
    #     // This means, all ip address are allowed to ssh ! 
    #     // Do not do it in the production. 
    #     // Put your office or home address in it!
    #     cidr_blocks = ["10.0.3.0/24"]
    # }
    # ingress {
    #     from_port = 80
    #     to_port = 80
    #     protocol = "tcp"
    #     cidr_blocks = ["10.0.3.0/24"]
    # }
    # ingress {
    #     from_port = 443
    #     to_port = 443
    #     protocol = "tcp"
    #     cidr_blocks = ["10.0.3.0/24"]
    # }

    tags = {
        Name = "tf-private-sg"
    }
}

// To Generate Private Key
resource "tls_private_key" "tfkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//variable "key_name" {
//  description = "Name of the SSH key pair"
//}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "tfkeypair" {
  key_name   = "tfkey"
  public_key = tls_private_key.tfkey.public_key_openssh
}

// Save PEM file locally
resource "local_file" "tfkey" {
  content  = tls_private_key.tfkey.private_key_pem
  filename = "tfkey.pem"
}


#Create public ec2
resource "aws_instance" "tf-public-ec2" {
    
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.subnet-public-tf.id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.tf-public-sg.id}"]
    # the Public SSH key
    key_name = aws_key_pair.tfkeypair.key_name
  
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
    
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.subnet-private-tf.id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.tf-private-sg.id}"]
    # the Public SSH key
    key_name = aws_key_pair.tfkeypair.key_name
  
    connection {
        user = "ubuntu"
        private_key = "${file("tfkey.pem")}"
    }

    tags = {
        Name = "tf-private-ec2"
    }
}

resource "aws_eip" "elastic-ip" {
  vpc = true 
  tags = {
    Name = "elastic-ip"
  }
}

#resource "aws_eip_association" "eip_assoc" {
 # instance_id   = aws_instance.tf-public-ec2.id
  #allocation_id = aws_eip.elastic-ip.id
#}


# create Nat gateway
resource "aws_nat_gateway" "tf-NatGateway" {
  allocation_id = aws_eip.elastic-ip.id
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.subnet-public-tf.id
  tags = {
    Name = "tf-NatGateway"
  }
}

resource "null_resource" "runtime" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
      echo '${tls_private_key.tfkey.private_key_pem}' > $HOME/.ssh/key.pem && chmod 600  $HOME/.ssh/key.pem
    EOF
  }
  
  provisioner "local-exec" {
    command = <<EOF
      chmod u+x ../scripts/inventory.sh && chmod u+x ../scripts/config.sh
      ../scripts/inventory.sh private_instance bastion
      ../scripts/config.sh ${aws_instance.tf-public-ec2.public_ip} ${aws_instance.tf-private-ec2.private_ip}
    EOF
  }

provisioner "local-exec" {
    command = <<EOF
      chmod u+x ../scripts/nginx.sh
      chmod u+x ../scripts/nginx-play.sh
      ../scripts/nginx-play.sh ${aws_instance.tf-public-ec2.public_ip} ${aws_instance.tf-private-ec2.private_ip}
    EOF
  }
}

output "public_ip" {
  value = aws_instance.tf-public-ec2.public_ip
}

output "private_ip" {
  value = aws_instance.tf-private-ec2.private_ip
}
