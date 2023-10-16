# Calgary Downtown Dental Office
## Infrastructure (Terraform)

### Author: Zhongyi Fu
### Email: z.fu177@mybvc.ca

## Prerequisite
* Terraform v1.5.7
* terragrunt version 0.52.1

## Terragrunt Commands

```bash
terragrunt init
terragrunt run-all plan
terragrunt run-all apply
```

## 1. Deploy VPC (Other modules depends on VPC)
```bash
terragrunt run-all plan --terragrunt-include-dir backend/vpc
terragrunt run-all apply --terragrunt-include-dir backend/vpc
```

## 2. Deploy All Others together
```bash
terragrunt run-all plan
terragrunt run-all apply
```