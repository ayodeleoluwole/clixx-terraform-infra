#Create auto-scaling group
resource "aws_autoscaling_group" "test-instance-asg" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = aws_subnet.private[*].id
  health_check_type    = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.clixx_launchTP1.id
    version = "$Latest"
  }

  #Attach to load Balancer target Group
  target_group_arns = [aws_lb_target_group.test-instance-tg.arn]


    tag {
    key                 = "Name"
    value               = "TestInstance-ASG-Server"
    propagate_at_launch = true
  }

  tag {
    key                 = "OwnerEmail"
    value               = "ayodeleoluwole112@gmail.com"
    propagate_at_launch = true
  }

  tag {
    key                 = "StackTeam"
    value               = "stackcloud9"
    propagate_at_launch = true
  }

  tag {
    key                 = "Schedule"
    value               = "A"
    propagate_at_launch = true
  }

  tag {
    key                 = "Backup"
    value               = "Yes"
    propagate_at_launch = true
  }
}
  resource "aws_autoscaling_policy" "clixx-autoscaling_policy" {
    name = "clixx-autoscaling_policy"
    policy_type = "TargetTrackingScaling"
    autoscaling_group_name = aws_autoscaling_group.test-instance-asg.name

    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50
      disable_scale_in = false
    }
    
  }

