resource "aws_route53_zone" "ha_project" {
  name = var.domain  # e.g., ha.mynsmdev.org
}

# Delegate subdomain from parent domain (mynsmdev.org)
resource "aws_route53_record" "test_subdomain_ns" {
  allow_overwrite = true
  zone_id = var.route53_zone_id   # <- parent zone ID (mynsmdev.org)
  name    = var.domain            # ha.mynsmdev.org
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.ha_project.name_servers
}

# These records should now point to the subdomain zone, not parent domain
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.ha_project.zone_id   # <- subdomain zone
  name    = var.domain                         # ha.mynsmdev.org
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.ha_project.zone_id   # <- subdomain zone
  name    = "www.${var.domain}"                # www.ha.mynsmdev.org
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
