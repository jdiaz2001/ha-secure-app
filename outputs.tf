# Output for the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# Output for the ALB DNS name
output "domain" {
  description = "The URL of the website server"
  value       = var.domain
}

# Output for DB instance Endpoint
output "mariaDB_endpoint" {
  description = "The endpoint of the MariaDB instance"
  value       = aws_db_instance.mariadb.address
}

# Output for EFS file system
output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.shared.id
}

# Output for the Bastion host DNS name
output "bastion_dns_name" {
  description = "The DNS name of the bastion host"
  value       = aws_instance.bastion.public_dns
}