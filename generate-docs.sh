#!/bin/sh
set -e

terraform-docs markdown modules/ecs-service/        > modules/ecs-service/README.md
terraform-docs markdown modules/ecs-background-job/ > modules/ecs-background-job/README.md
terraform-docs markdown modules/ecs-cluster/        > modules/ecs-cluster/README.md
terraform-docs markdown modules/load-balancer/      > modules/load-balancer/README.md
