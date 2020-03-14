resource "aws_instance" "jenkins" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  subnet_id = aws_subnet.main-public-1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = var.SSH_KEY_PAIR
  associate_public_ip_address = true
  user_data = data.template_cloudinit_config.cloudinit-jenkins.rendered
}

data "aws_eip" "jenkins" {
  tags = {
    Name = "Jenkins"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = data.aws_eip.jenkins.id
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "eu-west-2a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = var.INSTANCE_DEVICE_NAME
  volume_id   = aws_ebs_volume.ebs-volume-1.id
  instance_id = aws_instance.jenkins.id
}
