# Create VPC
resource "aws_vpc" "tf-vpc" {
    cidr_block              = var.vpc_cider
    enable_dns_support      = "true" #gives you an internal domain name
    enable_dns_hostnames    = "true" #gives you an internal host name
    instance_tenancy        = "default"
    tags = {
        Name = var.vpc_name
    }
}

# Create Internet gateway and attach it to the VPC
resource "aws_internet_gateway" "tf-igw" {
    vpc_id = aws_vpc.tf-vpc.id
    tags = {
        Name = "tf-igw"
    }
}


# Create Public subnet
resource "aws_subnet" "subnet-public-tf" {
    vpc_id                  = aws_vpc.tf-vpc.id
    cidr_block              = var.public_subnet_1a_cider
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone       = var.availability_zone_1a
    tags = {
        Name = "subnet-public-tf"
    }
}

# Create private subnet
resource "aws_subnet" "subnet-private-tf" {
    vpc_id                  = aws_vpc.tf-vpc.id
    cidr_block              = var.private_subnet_1b_cider
    map_public_ip_on_launch = "false" //it makes this a private subnet
    availability_zone       = var.availability_zone_1b
    tags = {
        Name = "subnet-private-tf"
    }
}


# Create Route Tables
resource "aws_route_table" "tf-public-rt" {
    vpc_id = aws_vpc.tf-vpc.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.tf-igw.id
    }

    # route {
    #     cidr_block = "10.0.0.0/16"
    #     gateway_id = "local"
    # }
    
    tags = {
        Name = "tf-public-rt"
    }
}

resource "aws_route_table_association" "tf-rta-public-subnet"{
    subnet_id       = aws_subnet.subnet-public-tf.id
    route_table_id  = aws_route_table.tf-public-rt.id
}

resource "aws_route_table" "tf-private-rt" {
    vpc_id = aws_vpc.tf-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.tf-NatGateway.id
    } 
    tags = {
        Name = "tf-private-rt"
    }
}

resource "aws_route_table_association" "tf-rta-private-subnet"{
    subnet_id       = aws_subnet.subnet-private-tf.id
    route_table_id  = aws_route_table.tf-private-rt.id
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