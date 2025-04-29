resource "aws_lb" "alb" {
  name               = "ha-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "ha_project" {
  name     = "ha-project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3   # 3 successful health checks to be considered healthy
    unhealthy_threshold = 2   # 2 failed health checks to be considered unhealthy
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ha_project" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ha_project.arn
  }
}
