resource "aws_efs_file_system" "shared" {
  creation_token = "ha-project-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  tags = {
    Name = "ha-project-efs"
  }
}

resource "aws_security_group" "efs_sg" {
  name_prefix = "efs-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id] # EC2s
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.efs_sg.id]
}
