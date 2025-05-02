resource "aws_db_subnet_group" "mariadb_subnet_group" {
  name       = "mariadb-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "mariadb-subnet-group"
  }
}

resource "aws_security_group" "mariadb_sg" {
  name_prefix = "mariadb-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mariadb-sg"
  }
}

resource "aws_db_instance" "mariadb" {
  identifier              = "ha-project-mariadb"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mariadb"
  engine_version          = "10.6.14"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.mariadb_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mariadb_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false
  backup_retention_period = 0 # Disable automatic backups to save cost

  tags = {
    Name = "ha-project-mariadb"
  }
}
