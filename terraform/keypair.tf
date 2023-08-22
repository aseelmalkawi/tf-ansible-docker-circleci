
// To Generate Private Key
resource "tls_private_key" "tfkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "tfkeypair" {
  key_name   = "tfkey"
  public_key = tls_private_key.tfkey.public_key_openssh
}

# Save PEM file locally
# resource "local_file" "tfkey" {
#   content  = tls_private_key.tfkey.private_key_pem
#   filename = "tfkey.pem"
# }
