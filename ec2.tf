resource "aws_instance" "webserver" {
  ami           = lookup(var.AMI, var.AWS_REGION)
  instance_type = "t3a.micro"
  # VPC
  subnet_id = aws_subnet.prod_subnet_public_1a.id
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.reza_sg.id}"]
  # the Public SSH key
  key_name = aws_key_pair.reza_keypair.id
  # nginx installation
  provisioner "file" {
    source      = "nginx.sh"
    destination = "/tmp/nginx.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.EC2_USER
    private_key = file(var.PRIVATE_KEY_PATH)
  }
}

resource "aws_instance" "dbserver" {
  ami           = lookup(var.AMI, var.AWS_REGION)
  instance_type = "t3a.micro"
  # VPC
  subnet_id = aws_subnet.prod_subnet_private_1a.id
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.reza_sg.id}"]
  # the Public SSH key
  key_name = aws_key_pair.reza_keypair.id
  # nginx installation
  provisioner "file" {
    source      = "mysql.sh"
    destination = "/tmp/mysql.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mysql.sh",
      "sudo /tmp/mysql.sh",
      "sleep 1m",
      "echo db server created"
    ]
  }
  connection {
    bastion_host = aws_instance.webserver.public_ip
    bastion_user = var.EC2_USER
    bastion_private_key = file(var.PRIVATE_KEY_PATH)

    host        = self.private_ip
    type        = "ssh"
    user        = var.EC2_USER
    private_key = file(var.PRIVATE_KEY_PATH)
    agent = false
  }
}
// Sends your public key to the instance
resource "aws_key_pair" "reza_keypair" {
  key_name   = "reza_keypair"
  public_key = file(var.PUBLIC_KEY_PATH)
}

