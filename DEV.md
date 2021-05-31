# Development configuration

## Generate module documentation

Install deps:
```
go get github.com/terraform-docs/terraform-docs
```

Generate documentation:
```
mkdir -p tmp/

terraform-docs markdown modules/ecs-service/        > tmp/ecs-service.md
terraform-docs markdown modules/ecs-background-job/ > tmp/ecs-background-job.md
terraform-docs markdown modules/ecs-cluster/        > tmp/ecs-cluster.md
terraform-docs markdown modules/load-balancer/      > tmp/load-balancer.md
```

then copy the output to appropriate READMEs.
