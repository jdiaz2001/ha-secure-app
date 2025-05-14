# ACM Certificate and Route53 DNS Validation
resource "aws_lb" "alb" {
  name               = "ha-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# Security Group for ALB
# This security group allows HTTP and HTTPS traffic from anywhere
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Target Group for ALB
resource "aws_lb_target_group" "ha_project" {
  name     = "ha-project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

# Health Check Configuration
  health_check {
  path                = "/healthcheck.html"
  interval            = 60        # Check every 60 seconds
  timeout             = 30        # Timeout after 30 seconds (must be < interval)
  healthy_threshold   = 5         # Needs 5 consecutive successful checks (5 mins)
  unhealthy_threshold = 10        # Fails after 10 consecutive failures (10 mins)
  matcher             = "200"
 }
}

# HTTP Listener: redirect to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener using ACM certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ha_project.arn
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb_waf" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.ha_project_waf.arn
}


