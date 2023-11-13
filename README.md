# Calgary Downtown Dental Office
## Infrastructure (Terraform)

### Author: Zhongyi Fu
### Email: z.fu177@mybvc.ca

## Prerequisite
* Terraform v1.5.7
* terragrunt version 0.52.1

## Before deployment
Update values in each terragrunt.hcl

## Terragrunt Commands

## 1. Deploy frontend
```bash
cd frontend
terragrunt plan
terragrunt apply
```

## 2. Deploy rds
```bash
cd backend/rds
terragrunt plan
terragrunt apply
```

## 3. Deploy ec2 (Depends on rds)
```bash
cd backend/ec2
terragrunt plan
terragrunt apply
```