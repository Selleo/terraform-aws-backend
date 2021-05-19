data "aws_region" "current" {}

locals {
  task_definition = "${aws_ecs_task_definition.this.family}:${max(
    aws_ecs_task_definition.this.revision,
    data.aws_ecs_task_definition.this.revision,
  )}"
}

resource "aws_ecs_task_definition" "this" {
  family = var.name

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
        portMappings      = [],
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
    field = "memory"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  tags = merge({ owner = "self" }, var.tags)
}

# logs

resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = var.log_retention_in_days

  tags = merge({ owner = "self" }, var.tags)
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
