output vpc_cider{
value = aws_vpc.tf-vpc.cidr_block
}

output "tf-vpc-id" {
    value = aws_vpc.tf-vpc.id
}

output "subnet-public-tf-ID" {
  value = aws_subnet.subnet-public-tf.id
}

output "subnet-private-tf-ID" {
  value = aws_subnet.subnet-private-tf.id
}
