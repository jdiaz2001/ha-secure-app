resource "aws_autoscaling_group" "ha_project" {
  name                      = "asg-project"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [aws_lb_target_group.ha_project.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ha_project.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    # give the instance a name based on the ASG name and instance ID
    value               = "ha-project-instance"
    propagate_at_launch = true
  }
}
