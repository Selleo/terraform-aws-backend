# ECS cluster

This folder contains a Terraform module to create an ECS cluster with Autoscaling Group.

## Usage

Define cluster:

```tf
module "ecs_cluster" {
  source  = "Selleo/backend/aws//modules/ecs-cluster"
  version = "0.2.0"

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.44.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.portal_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_placement_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_security_group.instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_outbound_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ephemeral_port_range](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_id.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.ecs_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ecs_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Image ID for Autoscaling group. If left blank, latest ECS-optimized version will be used. | `string` | `""` | no |
| <a name="input_autoscaling_group"></a> [autoscaling\_group](#input\_autoscaling\_group) | Autoscaling group configuration. | <pre>object({<br>    min_size         = number<br>    max_size         = number<br>    desired_capacity = number<br>  })</pre> | n/a | yes |
| <a name="input_backward_compatibility_single_instance_sg_per_vpc"></a> [backward\_compatibility\_single\_instance\_sg\_per\_vpc](#input\_backward\_compatibility\_single\_instance\_sg\_per\_vpc) | Use backward compatibility mode for security group name. If set to `True` default SG will be named `instance_sg`, otherwsie random prefix is added. | `bool` | `false` | no |
| <a name="input_ecs_loglevel"></a> [ecs\_loglevel](#input\_ecs\_loglevel) | ECS Cluster log level. | `string` | `"info"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type i.e. t3.medium. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key pair name for SSH access. | `string` | `""` | no |
| <a name="input_loadbalancer_sg_id"></a> [loadbalancer\_sg\_id](#input\_loadbalancer\_sg\_id) | LoadBalancer security group id. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix (hyphen suffix should be skipped). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for cluster. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups attached to launch configuration. | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of AWS subent IDs for Autoscaling group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags attached to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC id. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ECS cluster ID (contains randomized suffix). |
| <a name="output_instance_role"></a> [instance\_role](#output\_instance\_role) | IAM role that is attached to EC2 instances. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | Random prefix to use for associated resources. |
