# ECS cluster

This folder contains a Terraform module to create an ECS cluster with Autoscaling Group.

## Usage

Define cluster:

```tf
module "ecs_cluster" {
  source  = "Selleo/backend/aws//modules/ecs-cluster"
  version = "0.1.3"

  name_prefix        = "my-cluster"
  region             = "eu-central-1"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  instance_type      = "t3.micro"
  security_groups    = []
  loadbalancer_sg_id = module.lb.loadbalancer_sg_id

  autoscaling_group = {
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
  }
}
```

ECS cluster module requires VPC and subnets already set up as well load balancer with security group.
It is recommended to use [load-balancer](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/load-balancer) module.

For more details and options see source files.

## What's included in this module?

By default all resources names contain random prefix.

### ECS cluster with AWS autoscaling group

Module defines AWS Autoscaling Group with launch configuration template that configures ECS cluster.
Placement strategy is set to spread and termination policy is `OldestInstance`.
By default the latest ECS-optimized AMI for a given region is used unless specified otherwise. 

### Security group

Instance security group allows ingress traffic on ephemeral port range.

### IAM

Module defines permissions for EC2 instance that allows managing application lifecycle on ECS.

