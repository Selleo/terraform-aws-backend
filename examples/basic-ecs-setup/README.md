# Basic ECS example

See the [example](https://github.com/Selleo/terraform-aws-backend/tree/main/examples) source files 
or module specific documentation:

* [ECS cluster](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/ecs-cluster)
* [ECS background job](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/ecs-background-job)
* [ECS service](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/ecs-service)
* [Load balancer](https://registry.terraform.io/modules/Selleo/backend/aws/latest/submodules/load-balancer)


### ecs-service

Cluster:

```tf
module "ecs_cluster" {
  source  = "Selleo/backend/aws//modules/ecs-cluster"
  version = "0.6.1"

  name_prefix        = "my-cluster"
  region             = "eu-central-1" 
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  instance_type      = "t3.small"
  security_groups    = []
  loadbalancer_sg_id = module.lb.loadbalancer_sg_id

  autoscaling_group = {
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
  }

}
```

Optional cloudinit config:

```tf
module "ecs_cluster" {
  # ...
  cloudinit_parts = [
    {
      filename     = "hello.sh"
      content_type = "text/x-shellscript"
      content      = <<SH
  #!/usr/bin/env bash

  echo "Hello World" > /home/ec2-user/hello
  SH
    }
  ]
  # ...
}
```

### load-balancer

```tf
module "load_balancer" {
  source  = "Selleo/backend/aws//modules/load-balancer"
  version = "0.6.1"

  name       = "ecs-lb"
  vpc_id     = module.vpc.vpc_id          # "vpc-1234"
  subnet_ids = module.vpc.public_subnets  # ["10.0.101.0/24", "10.0.102.0/24"] 
}
```

### ecs-service

```tf
module "ecs_service" {
  source  = "Selleo/backend/aws//modules/ecs-service"
  version = "0.6.1"

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

### ecs-background-job


```tf
module "ecs_background_job" {
  source  = "Selleo/backend/aws//modules/ecs-background-job"
  version = "0.6.1"

  name           = "shoryuken"  
  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1
  instance_role  = module.ecs_cluster.instance_role
  
  container_definition = {
    cpu_units      = 256
    mem_units      = 512
    command        = ["bundle", "exec", "shoryuken", "-C", "config/shoryuken.yml", "-R"]
    image          = "${aws_ecr_repository.your_repo.repository_url}:latest"
    envs = { 
      MY_ENV = "sth"
    }
  }
}
```
