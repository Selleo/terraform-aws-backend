# ECS service

This folder contains a Terraform module to create an ECS service.

## Usage

Define service:

```tf
module "ecs_service" {
  source  = "Selleo/backend/aws//modules/ecs-service"
  version = "0.2.0"

  name           = "rails-api"
  vpc_id         = module.vpc.vpc_id
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1
  instance_role  = module.ecs_cluster.instance_role
  
  container_definition = {
    cpu_units      = 256
    mem_units      = 512
    command        = ["bundle", "exec", "ruby", "main.rb"],
    image          = "qbart/hello-ruby-sinatra:latest",
    container_port = 4567
    envs = {
      "APP_ENV" = "production"
    }
  }
}
```

ECS service module requires ECS cluster to be set up.
It is recommended to use [ecs-cluster](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/ecs-cluster) module.

For more details and options see source files.

## What's included in this module?

### Cloudwatch log group

Module creates a log group that is used by ECS service task.

### ECS service with task definition

Module configures ECS service with task that runs docker image.
Task is connected to load balancer using target group with default HTTP healthcheck at `/healthcheck`.
Task definition uses dynamic port mapping - you define container port and AWS will assign host port from ephemeral range.

Currently placement strategy is configured as follows:

1. spread / AZS
2. spread / instance
3. binpack / cpu
4. binpack / memory

### IAM

Module defines permissions that allow ECS service to be used with Load Balancer.
Additionally it creates a policy for instance role for logging.
