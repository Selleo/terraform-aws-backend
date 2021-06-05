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
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  # TODO: add to var 
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }

  #TODO https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config

  user_data = templatefile("${path.module}/scripts/user_data.sh.tpl",
    {
      ecs_cluster  = aws_ecs_cluster.this.name,
      ecs_loglevel = var.ecs_loglevel
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = random_id.prefix.hex

  tags = merge({ owner = "self" }, var.tags)
}

resource "aws_placement_group" "this" {
  name     = random_id.prefix.hex
  strategy = "spread" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html

  tags = merge({ owner = "self" }, var.tags)
}

resource "aws_autoscaling_group" "portal_autoscaling_group" {
  name                 = aws_launch_configuration.this.name
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

  tags = [
    for k, v in merge({ owner = "self" }, var.tags) : {
      key                 = k
      value               = v
      propagate_at_launch = true
    }
  ]

  force_delete = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = var.vpc_id
  name        = var.backward_compatibility_single_instance_sg_per_vpc ? "instance_sg" : "${random_id.prefix.hex}-instance"

  tags = merge({ owner = "self" }, var.tags)
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
