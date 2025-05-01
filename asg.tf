resource "aws_autoscaling_group" "ha_project" {
  name                      = "asg-project"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
#  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  vpc_zone_identifier       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  target_group_arns         = [aws_lb_target_group.ha_project.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

launch_template {
  id      = aws_launch_template.ha_project.id
  version = aws_launch_template.ha_project.latest_version
}

  tag {
    key                 = "Name"
    # give the instance a name based on the ASG name and instance ID
    value               = "ha-project-instance"
    propagate_at_launch = true
  }
}