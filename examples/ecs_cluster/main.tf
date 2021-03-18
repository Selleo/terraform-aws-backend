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

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix     = "test"
  region          = "eu-central-1"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.instance_sg.id]
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

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = module.vpc.vpc_id
  name        = "instance_sg"

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

resource "aws_security_group_rule" "ephemeral_port_range" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id
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

resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"
  vpc_id      = module.vpc.vpc_id
  name        = "test-lb-sg"

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
  security_group_id = aws_security_group.instance_sg.id
}

resource "aws_alb" "this" {
  name            = "selleo-test"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.lb_sg.id]
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

