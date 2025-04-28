variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "profile" {
  type = string
  description= "The AWS SSO profile to be used"
}

variable "vpc_id" {
  description = "VPC ID to launch resources in"
}

variable "subnet_ids" {
  description = "List of Subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
}

