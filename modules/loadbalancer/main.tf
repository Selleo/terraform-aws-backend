resource "aws_alb" "this" {
  name            = var.name
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.lb_sg.id]
  idle_timeout    = 1800

  tags = merge({ owner = "self" }, var.tags)
}

resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"
  vpc_id      = var.vpc_id
  name        = "lb-${var.name}"

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "allow_all_outbound_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

