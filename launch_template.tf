resource "aws_key_pair" "test-instance-kp" {
  key_name   = "test_instances_kp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

#Launch template for EC2
resource "aws_launch_template" "clixx_launchTP1" {
  name                      = "Clix_Template"
  image_id                  = var.ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.ec2-sg.id]
  user_data                 = base64encode(data.template_file.bootstrap.rendered)
  key_name                  = aws_key_pair.test-instance-kp.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "TestInstance-SB-Server"
      OwnerEmail  = "ayodeleoluwole112@gmail.com"
      StackTeam   = "stackcloud9"
      Schedule    = "A"
      Backup      = "Yes"
    }
  }
}