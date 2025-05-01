# Output for the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "domain" {
  description = "The URL of the website server"
  value       = var.domain
  }
