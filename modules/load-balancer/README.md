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
