data "aws_region" "current" {}

locals {
  task_definition = "${aws_ecs_task_definition.this.family}:${max(
    aws_ecs_task_definition.this.revision,
    data.aws_ecs_task_definition.this.revision,
  )}"

  container_definition_overrides = {
    command = var.command
  }
}

resource "random_id" "prefix" {
  byte_length = 4
  prefix      = "${var.name}-"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family = var.name

  container_definitions = jsonencode(
    [
      merge({
        essential         = true,
        memoryReservation = var.container.mem_units,
        cpu               = var.container.cpu_units,
        name              = var.name,
        image             = var.container.image,
        mountPoints       = [],
        volumesFrom       = [],
        portMappings = [
          {
            containerPort = var.container.port,
            hostPort      = 0,
            protocol      = "tcp",
          },
        ],

        environment = [
          for k, v in var.container.envs :
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
      }, length(var.command) == 0 ? {} : local.container_definition_overrides) # merge only if command not empty
  ])

  tags = var.tags
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
    container_port   = var.container.port
  }

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

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

  tags = var.tags
}

resource "aws_iam_role" "ecs" {
  name               = "${random_id.prefix.hex}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs.json

  tags = var.tags
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
  port                 = var.container.port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30 # draining time

  health_check {
    path                = var.health_check.path
    protocol            = "HTTP"
    timeout             = 10
    interval            = 15
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = var.health_check.matcher
  }

  tags = var.tags
}
