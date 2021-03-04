module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix   = "test"
  region        = "eu-central-1"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.public_subnets
  instance_type = "t3.micro"
  autoscaling_group = {
    min_size         = 1
    max_size         = 1
    desired_capacity = 1
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "test"
  retention_in_days = 365

  tags = {
    owner = "self"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = "test_task_definition"
  container_definitions = jsonencode(
    [
      {
        essential         = true,
        memoryReservation = 256,
        cpu               = 128,
        name              = "test",
        command           = ["bundle", "exec", "ruby", "main.rb"],
        image             = "qbart/hello-ruby-sinatra:latest",
        mountPoints       = [],
        volumesFrom       = [],
        portMappings = [
          {
            containerPort = 4567,
            hostPort      = 0,
            protocol      = "tcp",
          },
        ],
        environment = [],
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group  = aws_cloudwatch_log_group.this.name,
            awslogs-region = "eu-central-1",
          },
        },
      }
  ])

  tags = {
    owner = "self"
  }
}

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}

resource "aws_ecs_service" "this" {
  name    = "test_service"
  cluster = module.ecs_cluster.ecs_cluster_id
  task_definition = "${aws_ecs_task_definition.this.family}:${max(
    aws_ecs_task_definition.this.revision,
    data.aws_ecs_task_definition.this.revision,
  )}"
  # iam_role        = "TODO"
  # load_balancer
  desired_count                      = 1
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

  tags = {
    owner = "self"
  }
}

