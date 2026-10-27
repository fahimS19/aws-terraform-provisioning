
.PHONY: fmt validate plan-dev plan-staging plan-prod destroy-dev

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate

plan-dev:
	terraform plan -var-file=envs/dev.tfvars

plan-staging:
	terraform plan -var-file=envs/staging.tfvars

plan-prod:
	terraform plan -var-file=envs/prod.tfvars

destroy-dev:
	terraform destroy -var-file=envs/dev.tfvars

destroy-staging:
	terraform destroy -var-file=envs/staging.tfvars

destroy-prod:
	terraform destroy -var-file=envs/prod.tfvars
