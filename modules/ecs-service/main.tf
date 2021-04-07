data "aws_region" "current" {}

locals {
  task_definition = "${aws_ecs_task_definition.this.family}:${max(
    aws_ecs_task_definition.this.revision,
    data.aws_ecs_task_definition.this.revision,
  )}"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = 365

  tags = merge({ owner = "self" }, var.tags)
}

resource "aws_ecs_task_definition" "this" {
  family = "test_task_definition"
  container_definitions = jsonencode(
    [
      {
        essential         = true,
        memoryReservation = var.container_definition.mem_units,
        cpu               = var.container_definition.cpu_units,
        name              = var.name,
        command           = var.container_definition.command,
        image             = var.container_definition.image,
        mountPoints       = [],
        volumesFrom       = [],
        portMappings = [
          {
            containerPort = var.container_definition.container_port,
            hostPort      = 0,
            protocol      = "tcp",
          },
        ],
        environment = [
          for k, v in var.container_definition.envs :
          {
            name  = k
            value = v
          }
        ],
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group  = aws_cloudwatch_log_group.this.name,
            awslogs-region = data.aws_region.current.name,
          },
        },
      }
  ])

  tags = merge({ owner = "self" }, var.tags)
}

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}


resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.ecs_cluster_id
  task_definition = local.task_definition
  iam_role        = aws_iam_role.ecs.arn

  load_balancer {
    target_group_arn = aws_alb_target_group.this.arn
    container_name   = var.name
    container_port   = var.container_definition.container_port
  }

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.avaiability-zones"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  tags = merge({ owner = "self" }, var.tags)
}

resource "aws_iam_role" "ecs" {
  name               = "${var.name}-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs.json

  tags = merge({ owner = "self" }, var.tags)
}

data "aws_iam_policy_document" "ecs" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "${var.name}-role-cloudwatch-policy"
  role   = var.instance_role
  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }
}

resource "aws_iam_role_policy" "alb" {
  name   = "${var.name}-role-alb-policy"
  role   = aws_iam_role.ecs.name
  policy = data.aws_iam_policy_document.alb.json
}

data "aws_iam_policy_document" "alb" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]

    resources = ["*"]
  }
}

resource "aws_alb_target_group" "this" {
  name                 = var.name
  port                 = var.container_definition.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30 # draining time

  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    timeout             = 10
    interval            = 15
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge({ owner = "self" }, var.tags)
}
