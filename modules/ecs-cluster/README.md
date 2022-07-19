## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.44.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
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
| [cloudinit_config.this](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Image ID for Autoscaling group. If left blank, latest ECS-optimized version will be used. | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public ip address with an instance in a VPC. | `bool` | `true` | no |
| <a name="input_autoscaling_group"></a> [autoscaling\_group](#input\_autoscaling\_group) | Autoscaling group configuration. | <pre>object({<br>    min_size         = number<br>    max_size         = number<br>    desired_capacity = number<br>  })</pre> | <pre>{<br>  "desired_capacity": 2,<br>  "max_size": 5,<br>  "min_size": 1<br>}</pre> | no |
| <a name="input_cloudinit_parts"></a> [cloudinit\_parts](#input\_cloudinit\_parts) | Parts for cloud-init config that are added to the final MIME document. | <pre>list(object({<br>    content      = string<br>    filename     = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloudinit_scripts"></a> [cloudinit\_scripts](#input\_cloudinit\_scripts) | Shell scripts added to cloud-init. | `list(string)` | `[]` | no |
| <a name="input_ecs_loglevel"></a> [ecs\_loglevel](#input\_ecs\_loglevel) | ECS Cluster log level. | `string` | `"info"` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable container insights for the cluster. | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type i.e. t3.medium. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key pair name for SSH access. | `string` | `""` | no |
| <a name="input_lb_security_group_id"></a> [lb\_security\_group\_id](#input\_lb\_security\_group\_id) | Load balancer security group id. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix (hyphen suffix should be skipped). | `string` | n/a | yes |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Placement group strategy. | <pre>object({<br>    strategy     = string<br>    spread_level = string<br>  })</pre> | <pre>{<br>  "spread_level": "rack",<br>  "strategy": "spread"<br>}</pre> | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | If protect from scale in is enabled, newly launched instances will be protected from scale in by default. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for cluster. | `string` | n/a | yes |
| <a name="input_root_block_configuration"></a> [root\_block\_configuration](#input\_root\_block\_configuration) | Configuration for root block device block. | <pre>object({<br>    volume_type = string<br>    volume_size = number<br>  })</pre> | <pre>{<br>  "volume_size": 30,<br>  "volume_type": "gp2"<br>}</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups attached to launch configuration. | `list(string)` | `[]` | no |
| <a name="input_ssm_tag_key"></a> [ssm\_tag\_key](#input\_ssm\_tag\_key) | Tag key to add for SSM access | `string` | `"SSMAccess"` | no |
| <a name="input_ssm_tag_value"></a> [ssm\_tag\_value](#input\_ssm\_tag\_value) | Tag value to add for SSM access | `string` | `"true"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of AWS subent IDs for Autoscaling group. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags attached to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC id. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | Autoscaling Group data. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ECS cluster ID (contains randomized suffix). |
| <a name="output_instance_role"></a> [instance\_role](#output\_instance\_role) | IAM role that is attached to EC2 instances. |
| <a name="output_instance_security_group_id"></a> [instance\_security\_group\_id](#output\_instance\_security\_group\_id) | ID of the security group attached to an instance. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | Random prefix to use for associated resources. |
