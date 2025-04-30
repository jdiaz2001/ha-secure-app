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
