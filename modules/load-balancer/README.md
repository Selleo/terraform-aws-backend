# Load balancer

This folder contains a Terraform module to create an application load balancer with default security group configuration allowing web traffic.
In order to use this module you need to have networking set up - you can use official [Hashicorp AWS VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to do that.

## Usage

Define application load balancer:

```tf
module "lb" {
  source  = "Selleo/backend/aws//modules/load-balancer"
  version = "0.2.0"

  name       = "ecs-lb"
  vpc_id     = "vpc-1234"
  subnet_ids = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

For more details and options see source files.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_security_group.lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_outbound_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Access logs config for load balancer. | <pre>object({<br>    bucket  = string<br>    prefix  = string<br>    enabled = bool<br>  })</pre> | <pre>{<br>  "bucket": "",<br>  "enabled": false,<br>  "prefix": ""<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Load balancer name. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of AWS subent IDs for Autoscaling group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags attached to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_loadbalancer_dns_name"></a> [loadbalancer\_dns\_name](#output\_loadbalancer\_dns\_name) | n/a |
| <a name="output_loadbalancer_id"></a> [loadbalancer\_id](#output\_loadbalancer\_id) | n/a |
| <a name="output_loadbalancer_sg_id"></a> [loadbalancer\_sg\_id](#output\_loadbalancer\_sg\_id) | n/a |
| <a name="output_loadbalancer_zone_id"></a> [loadbalancer\_zone\_id](#output\_loadbalancer\_zone\_id) | n/a |
