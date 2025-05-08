resource "aws_launch_template" "ha_project" {
  name_prefix   = "template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

iam_instance_profile {
  arn = aws_iam_instance_profile.ssm_instance_profile.arn
}

user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
  username       = var.new_user,
  password       = var.new_password,
  server_name    = var.domain,
  db_username    = var.db_username,
  db_password    = var.db_password,
  db_endpoint    = aws_db_instance.mariadb.address,
  efs_id         = aws_efs_file_system.shared.id
  logs_script    = file("${path.module}/scripts/05-logs.sh"),
  user_script    = file("${path.module}/scripts/02-user.sh"),
  apache_script   = file("${path.module}/scripts/01-apache.sh"),
  rds_script     = file("${path.module}/scripts/04-rds.sh"),
  opencart_script = file("${path.module}/scripts/06-opencart.sh"),
  oc_config_script = file("${path.module}/scripts/07-oc-config.sh"),
  efs_script     = file("${path.module}/scripts/03-efs.sh"),
  update_script  = file("${path.module}/scripts/09-system-update.sh")
}))

# No Public IP on the instances
vpc_security_group_ids = [aws_security_group.instance_sg.id]

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