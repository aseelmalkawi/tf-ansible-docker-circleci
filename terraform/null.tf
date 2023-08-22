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
