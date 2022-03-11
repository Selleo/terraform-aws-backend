# ECS background job

This folder contains a Terraform module to create an ECS background job.

## Usage

Define background job:

```tf
module "ecs_background_job" {
  source  = "Selleo/backend/aws//modules/ecs-background-job"
  version = "0.6.0"

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_definition"></a> [container\_definition](#input\_container\_definition) | Service container configuration. | <pre>object({<br>    cpu_units = number<br>    mem_units = number<br>    command   = list(string)<br>    image     = string<br>    envs      = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired task count. | `number` | n/a | yes |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ECS Cluster id. | `string` | n/a | yes |
| <a name="input_instance_role"></a> [instance\_role](#input\_instance\_role) | EC2 instance role. | `string` | n/a | yes |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Log retention in days for Cloudwatch. | `string` | `365` | no |
| <a name="input_name"></a> [name](#input\_name) | ECS Service name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags attached to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ARN that identifies the service. |
| <a name="output_task_definition"></a> [task\_definition](#output\_task\_definition) | Latest task definition (family:revision). |
| <a name="output_task_family"></a> [task\_family](#output\_task\_family) | ECS task family. |
