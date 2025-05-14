# Route53 configuration
resource "aws_route53_zone" "ha_project" {
  name = var.domain
}

# Delegate subdomain from parent domain
resource "aws_route53_record" "test_subdomain_ns" {
  allow_overwrite = true
  zone_id = var.route53_zone_id   # parent zone ID (Apex Domain)
  name    = var.domain            # Sub domain
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.ha_project.name_servers
}

# These records should now point to the subdomain zone, not parent domain
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.ha_project.zone_id  
  name    = var.domain                         
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# WWW record for the subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.ha_project.zone_id   
  name    = "www.${var.domain}"                
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
