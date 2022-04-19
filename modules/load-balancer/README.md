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
| [aws_alb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_security_group.lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_outbound_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Access logs config for load balancer. | <pre>object({<br>    bucket  = string<br>    prefix  = string<br>    enabled = bool<br>  })</pre> | <pre>{<br>  "bucket": "",<br>  "enabled": false,<br>  "prefix": ""<br>}</pre> | no |
| <a name="input_allow_all_outbound"></a> [allow\_all\_outbound](#input\_allow\_all\_outbound) | Create ingress rule for port 443. | `bool` | `true` | no |
| <a name="input_allow_http"></a> [allow\_http](#input\_allow\_http) | Create ingress rule for port 80. | `bool` | `true` | no |
| <a name="input_allow_https"></a> [allow\_https](#input\_allow\_https) | Create ingress rule for port 443. | `bool` | `true` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | CIDR blocks used for ingress rules. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Load balancer name. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of AWS subent IDs for Autoscaling group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags attached to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_id"></a> [id](#output\_id) | The ARN of the load balancer. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group attached to the load balancer. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
