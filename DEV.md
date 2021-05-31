# Development configuration

## Generate module documentation

Install deps:
```
go get github.com/terraform-docs/terraform-docs
```

Generate documentation:
```
terraform-docs markdown modules/ecs-service/
```

then copy the output to appropriate README.
