output "public_ip" {
  value = aws_instance.tf-public-ec2.public_ip
}

output "private_ip" {
  value = aws_instance.tf-private-ec2.private_ip
}