# Key pair for EC2 instance
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykey"
  public_key = file(var.key_name)
}

