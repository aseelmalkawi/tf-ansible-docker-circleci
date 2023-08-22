#Create public security group
resource "aws_security_group" "tf-public-sg" {
    vpc_id = module.network.tf-vpc-id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1 //All traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        // This means, all ip address are allowed to ssh ! 
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow ssh"
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow http"
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow https"
    }

    tags = {
        Name = "tf-public-sg"
    }
}

#Create private security group
resource "aws_security_group" "tf-private-sg" {
    vpc_id = module.network.tf-vpc-id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1 //All traffic
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 65535  # All TCP ports
        protocol    = "tcp"
        cidr_blocks = ["10.0.3.0/24"]  
    }

    ingress {
        from_port       = 0
        to_port         = 65535  # All TCP ports
        protocol        = "tcp"
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

