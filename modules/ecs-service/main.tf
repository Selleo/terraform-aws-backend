locals {
  container_definitions = defaults(var.container_definitions, {
    desired_count = 1
    cpu_units     = 256
    mem_units     = 128
    envs          = {}
  })
}

data "aws_region" "current" {}

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
        memoryReservation = local.container_definition.mem_units,
        cpu               = local.container_definition.cpu_units,
        name              = var.name,
        command           = local.container_definition.command,
        image             = local.container_definition.image,
        mountPoints       = [],
        volumesFrom       = [],
        portMappings = [
          {
            containerPort = local.container_definition.port,
            hostPort      = 0,
            protocol      = "tcp",
          },
        ],
        environment = [
          for k, v in local.container_definition.envs :
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
  name    = var.name
  cluster = var.ecs_cluster_id
  task_definition = "${aws_ecs_task_definition.this.family}:${max(
    aws_ecs_task_definition.this.revision,
    data.aws_ecs_task_definition.this.revision,
  )}"
  # iam_role        = "TODO"
  # load_balancer
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

# data "aws_iam_policy_document" "cloudwatch_instance" {
#   statement {
#     effect = "Allow"
#     actions = [
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#     ]
# 
#     resource = ["*"]
#   }
# }
