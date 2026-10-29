resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data == null ? null : base64encode(var.user_data)

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name == null ? [] : [1]

    content {
      name = var.iam_instance_profile_name
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = var.name
      }
    )
  }

  update_default_version = true
}

resource "aws_autoscaling_group" "this" {
  name                = var.name
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns

  health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

    triggers = ["tag"]
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = var.name
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}