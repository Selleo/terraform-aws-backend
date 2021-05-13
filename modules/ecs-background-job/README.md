# ECS background job

This folder contains a Terraform module to create an ECS background job.

## Usage

Define background job:

```tf
module "ecs_background_job" {
  source  = "Selleo/backend/aws//modules/ecs-background-job"
  version = "0.1.8"

  name           = "shoryuken"  
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1
  instance_role  = module.ecs_cluster.instance_role
  
  container_definition = {
    cpu_units      = 256
    mem_units      = 512
    command        = ["bundle", "exec", "ruby", "main.rb"],
    image          = "qbart/hello-ruby-sinatra:latest",
    envs = {
      "APP_ENV" = "production"
    }
  }
}
```

ECS background job module requires ECS cluster to be set up.
It is recommended to use [ecs-cluster](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/ecs-cluster) module.

For more details and options see source files.

## What's included in this module?

### Cloudwatch log group

Module creates a log group that is used by ECS background job task.

### ECS background job with task definition

Module configures ECS background job with task that runs docker image.

Currently placement strategy is configured as follows:

1. spread / AZS
2. spread / instance
3. binpack / memory
4. binpack / cpu

### IAM

Module defines a policy for instance role for logging.
