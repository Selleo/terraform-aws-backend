module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  name       = "ecs-lb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix        = "test"
  region             = "eu-central-1"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  instance_type      = "t3.micro"
  security_groups    = []
  loadbalancer_sg_id = module.loadbalancer.loadbalancer_sg_id
  autoscaling_group = {
    min_size         = 1
    max_size         = 1
    desired_capacity = 1
  }
}

module "ecs_service" {
  source = "../../modules/ecs-service"

  name           = "test"
  vpc_id         = module.vpc.vpc_id
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1
  instance_role  = module.ecs_cluster.instance_role
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

resource "aws_alb_listener" "http" {
  load_balancer_arn = module.loadbalancer.loadbalancer_id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = module.ecs_service.lb_target_group_id
    type             = "forward"
  }
}

# resource "aws_alb_listener" "https" {
#   load_balancer_arn = aws_alb.this.id
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.cert_arn
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01" # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

#   default_action {
#     target_group_arn = aws_alb_target_group.this.id
#     type             = "forward"
#   }
# }

