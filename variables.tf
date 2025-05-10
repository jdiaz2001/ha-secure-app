variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "profile" {
  type = string
  description= "The AWS SSO profile to be used"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
}

variable "new_password" {
  description = "Password for ubuntu user"
  type        = string
}

variable "new_user" {
  description = "New user to be created"
  type        = string
  
}

variable "key_name" {
  default = "mykey.pub"
}

variable "local_ip" {
  default = "my_ip"
}

variable "domain" {
  type = string
  description= "The domain name for the Load Balancer"
}

variable "route53_zone_id" {
  type = string
  description= "The Route53 zone_id for the domain"
}

variable "db_username" {
  type        = string
  description = "MariaDB admin username"
}

variable "db_password" {
  type        = string
  description = "MariaDB password"
  sensitive   = true
}

variable "install_dir" {
  type        = string
  description = "Directory for OpenCart installation"
}
