# Development configuration

## Updating ingore files

Make sure `.gitignore` and `.terraformignore` files contain necessary rules.

## Generate module documentation

Install deps:
```
go get github.com/terraform-docs/terraform-docs
```

Generate documentation:
```
./generate-docs.sh
```

## Releasing

Make sure to update changelog.

