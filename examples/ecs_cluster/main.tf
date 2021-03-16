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

module "ecs_service" {
  source = "../../modules/ecs-service"

  name           = "test"
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1
  container_definition = {
    cpu_units      = 256
    mem_units      = 256
    command        = ["bundle", "exec", "ruby", "main.rb"],
    image          = "qbart/hello-ruby-sinatra:latest",
    container_port = 4567
    envs = {
      "APP_ENV" = "production"
    }
  }
}

resource "aws_alb" "this" {
  name            = "${var.environment}-${var.app_name}"
  subnets         = module.vpc.public_subnets
  security_groups = [TODO]
  idle_timeout    = 1800

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.this.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.cert_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01" # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

  default_action {
    target_group_arn = aws_alb_target_group.this.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "this" {
  name                 = "tg"
  port                 = var.app.port
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
    matcher             = "200-308"
  }

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}
