locals {
  ami = var.ami == "" ? data.aws_ami.ecs_optimized.id : var.ami
}

resource "random_id" "prefix" {
  byte_length = 4
  prefix      = "${var.name_prefix}-"
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${random_id.prefix.hex}-"
  image_id                    = local.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = concat([aws_security_group.instance_sg.id], var.security_groups)
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  root_block_device {
    volume_type = var.root_block_configuration.volume_type
    volume_size = var.root_block_configuration.volume_size
  }

  user_data_base64 = data.cloudinit_config.this.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = random_id.prefix.hex

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_placement_group" "this" {
  name         = random_id.prefix.hex
  strategy     = var.placement_group.strategy # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html
  spread_level = var.placement_group.spread_level

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name                 = random_id.prefix.hex
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier  = var.subnet_ids

  min_size         = var.autoscaling_group.min_size
  desired_capacity = var.autoscaling_group.desired_capacity
  max_size         = var.autoscaling_group.max_size

  placement_group      = aws_placement_group.this.id
  termination_policies = ["OldestInstance"]

  default_cooldown          = 300
  wait_for_capacity_timeout = "480s"
  health_check_grace_period = 15
  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = random_id.prefix.hex
    propagate_at_launch = true
  }

  tag {
    key                 = var.ssm_tag_key
    value               = var.ssm_tag_value
    propagate_at_launch = true
  }

  tag {
    key                 = "ssm.group"
    value               = var.ssm_tag_value
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  force_delete = false

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }
}

resource "aws_security_group" "instance_sg" {
  description = "Controls direct access to application instances"
  vpc_id      = var.vpc_id
  name        = "${random_id.prefix.hex}-instance"

  tags = var.tags
}

resource "aws_security_group_rule" "ephemeral_port_range" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.loadbalancer_sg_id
  security_group_id        = aws_security_group.instance_sg.id
}

resource "aws_security_group_rule" "allow_all_outbound_ec2_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance_sg.id
}

data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ecs-init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/user_data.sh.tpl",
      {
        ecs_cluster  = aws_ecs_cluster.this.name,
        ecs_loglevel = var.ecs_loglevel,
        ecs_tags = jsonencode(merge(var.tags, {
          "Name"      = random_id.prefix.hex,
          "ssm.group" = var.ssm_tag_value,
        }))  
      }
    )
  }

  dynamic "part" {
    for_each = var.cloudinit_parts
    content {
      filename     = part.value["filename"]
      content      = part.value["content"]
      content_type = part.value["content_type"]
    }
  }
}
