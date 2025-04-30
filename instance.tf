resource "aws_launch_template" "ha_project" {
  name_prefix   = "template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

iam_instance_profile {
  arn = aws_iam_instance_profile.ssm_instance_profile.arn
}

user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
  username = var.new_user,
  password = var.new_password
}))
  
network_interfaces {
  associate_public_ip_address = true
  security_groups             = [aws_security_group.instance_sg.id]
}

# the public SSH key
key_name = aws_key_pair.mykeypair.key_name

tag_specifications {
  resource_type = "instance"
  tags = {
    Name = "project"
    Environment = "ha_project"
  }
 }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg-"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
