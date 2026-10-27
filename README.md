# Terraform AWS Infrastructure Assignment

[![Terraform
CI](https://github.com/fahimS19/terraform-assignment-fahim30246/actions/workflows/terraform.yaml/badge.svg)](https://github.com/fahimS19/terraform-assignment-fahim30246/actions/workflows/terraform.yaml)

A reusable, flat-file Terraform project that demonstrates how to define
a small AWS application-infrastructure baseline for **development,
staging, and production** using one root configuration and separate
`.tfvars` files.

> **Cost and safety first:** This project is designed for a low-cost
> exercise. Only the `dev` environment should be applied. Staging and
> production are plan-only, and development resources must be destroyed
> after verification. AWS charges depend on region, usage, account
> settings, and current pricing; the `$5` target is not a billing
> guarantee.

## Contents

- [Project purpose](#project-purpose)
- [Architecture overview](#architecture-overview)
- [Folder structure](#folder-structure)
- [AWS services used](#aws-services-used)
- [Environment strategy](#environment-strategy)
- [Terraform features demonstrated](#terraform-features-demonstrated)
- [Cost estimate and safety rules](#cost-estimate-and-safety-rules)
- [Prerequisites](#prerequisites)
- [How to run development](#how-to-run-development)
- [How to plan staging and
  production](#how-to-plan-staging-and-production)
- [How to destroy development
  resources](#how-to-destroy-development-resources)
- [Makefile shortcuts](#makefile-shortcuts)
- [GitHub Actions CI](#github-actions-ci)
- [Known limitations](#known-limitations)

## Project purpose

The goal is to build one reusable Terraform configuration that creates a
small set of AWS resources and changes its behavior according to the
selected environment file.

The project follows the assignment's key constraints:

- Use a **flat Terraform structure** in the root directory; do not use
  Terraform modules.
- Keep environment-specific values in `envs/dev.tfvars`,
  `envs/staging.tfvars`, and `envs/prod.tfvars`.
- Use locals and computed names instead of hardcoding separate
  resource names for each environment.
- Demonstrate conditional resource creation, `count`, `for_each`,
  dynamic blocks, variable validation, and safe outputs.
- Apply only development resources, produce plans for staging and
  production, and destroy development resources after testing.
- Avoid prohibited services such as NAT Gateways, load balancers, RDS,
  EKS, OpenSearch, and Elastic IPs.

## Architecture overview

The root Terraform configuration manages the following resource types:

- An S3 bucket for application artifacts or configuration, with public
  access blocked and ownership controls configured.
- An optional S3 lifecycle rule for expiring old objects.
- A DynamoDB configuration table using `PAY_PER_REQUEST` billing.
- An IAM role, policy, and role-policy attachment for a demonstration
  application access pattern.
- Standard-tier SSM String parameters.
- CloudWatch log groups with configured retention periods.
- A security group with ingress controlled by variables.
- An optional EC2 test instance, disabled by default.

The EC2 instance is intentionally left disabled to avoid compute
charges. The architecture diagram and resource details are documented in
[`docs/architecture.md`](docs/architecture.md).

## Folder structure

```text
terraform-assignment/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── data.tf
├── s3.tf
├── dynamodb.tf
├── iam.tf
├── ssm.tf
├── cloudwatch.tf
├── security-group.tf
├── ec2-optional.tf
├── outputs.tf
├── backend-example.tf
├── .gitignore
├── .terraform.lock.hcl
├── Makefile
├── README.md
├── .github/
│   └── workflows/
│       └── terraform.yml
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── docs/
│   ├── architecture.md
│   └── cost-notes.md
└── evidence/
    ├── init.txt
    ├── fmt.txt
    ├── validate.txt
    ├── plan-dev.txt
    ├── plan-staging.txt
    ├── plan-prod.txt
    ├── apply-dev.txt
    ├── output-dev.txt
    └── destroy-dev.txt
```

The `.terraform/` directory, Terraform state files, and saved plan files
are generated locally and should not be committed.

## AWS services used

Service Purpose Cost/safety approach

---

Amazon S3 Artifact/configuration Public access blocked;
bucket lifecycle rule is
optional

Amazon DynamoDB Configuration/metadata `PAY_PER_REQUEST`
table billing

AWS IAM Role and least-privilege IAM itself has no
example policy additional charge

AWS Systems Manager Standard `String` Does not use Advanced
Parameter Store parameters parameters

Amazon CloudWatch Logs Application/worker log Short retention
groups configured by
environment

Amazon VPC Security Example network access Security group creation
Groups rules has no direct hourly
charge

Amazon EC2 Optional test instance Disabled by default; do
not enable for this
assignment

---

No NAT Gateway, Application/Network Load Balancer, RDS, EKS, OpenSearch,
or Elastic IP is provisioned by this project.

## Environment strategy

The same root configuration is parameterized by the selected `.tfvars`
file.

Setting Dev Staging Prod

---

S3 versioning Disabled Enabled Enabled
DynamoDB Enabled Enabled Enabled
IAM role/policy Enabled Enabled Enabled
SSM parameters Enabled Enabled Enabled
CloudWatch log groups Enabled Enabled Enabled
EC2 test instance Disabled Disabled Disabled
Intended workflow Apply, verify, destroy Plan only Plan only
`prevent_destroy` input `false` `false` `true`

The environment files should be reviewed before running any command. The
production configuration is for planning only in this assignment.

## Terraform features demonstrated

### Locals and naming

`locals.tf` defines shared environment abbreviations, region
abbreviations, a naming prefix, and common tags. Resource names are
assembled from variables and locals so that the same configuration can
be reused across environments.

### `count` versus `for_each`

- **`count`** is used for resources that are either enabled once or
  disabled, such as the optional DynamoDB table, IAM resources,
  lifecycle configuration, and optional EC2 instance.
- **`for_each`** is used for collections of independently named
  resources, such as SSM parameters and CloudWatch log groups.

### Conditional expressions

Ternary expressions select settings and decide whether optional
resources should exist. This lets environment configuration control
behavior without duplicating the root Terraform code.

### Dynamic blocks

Dynamic blocks generate nested configuration from input values. The
project uses dynamic configuration where applicable, including IAM
policy statements and the optional S3 lifecycle expiration
configuration.

### Variable validation

Input validation restricts supported environments, naming formats,
regions, lifecycle values, log retention values, and unsafe combinations
such as enabling the optional EC2 test instance in production.

### Safe outputs

Outputs return resource names and ARNs for enabled resources. Optional
resources use conditional expressions so their outputs can be `null`
when disabled, rather than indexing a resource that does not exist.

### Environment files

The environment files supply different values to the same Terraform
configuration:

```bash
terraform plan -var-file=envs/dev.tfvars
terraform plan -var-file=envs/staging.tfvars
terraform plan -var-file=envs/prod.tfvars
```

A `.tfvars` file changes input values; it does not create an independent
Terraform state. This assignment applies only dev and plans the other
environments.

## Cost estimate and safety rules

This project aims to keep actual AWS charges below the assignment's
**\$5 target**, but costs cannot be guaranteed from Terraform
configuration alone.

- S3, DynamoDB on-demand, standard SSM parameters, and CloudWatch Logs
  can incur usage-based charges.
- CloudWatch ingestion and storage depend on the amount of log data.
- S3 storage and requests depend on usage.
- DynamoDB `PAY_PER_REQUEST` avoids provisioned capacity charges but
  still charges for requests and storage.
- IAM roles/policies and security group creation have no direct hourly
  resource charge.
- EC2 is disabled by default and must remain disabled for this
  exercise.
- Do not create prohibited or high-cost infrastructure.
- Review the plan before applying; never apply staging or production.
- Verify resources in the AWS Console and destroy development
  resources when finished.
- Check AWS Billing and Cost Explorer after the exercise. Billing data
  may be delayed.

See [`docs/cost-notes.md`](docs/cost-notes.md) for the project-specific
cost and safety notes.

## Prerequisites

Install and configure the following:

1.  Terraform CLI (compatible with the version constraint in
    `versions.tf`).
2.  AWS CLI and credentials for an AWS identity allowed to create and
    delete the listed resources.
3.  Git.
4.  GNU Make, if you want to use the Makefile shortcuts.

Check the installations:

```bash
terraform version
aws --version
git --version
make --version
```

Check which AWS identity is active before creating resources:

```bash
aws sts get-caller-identity
aws configure list
```

Use your normal AWS credential mechanism. **Never place access keys or
secret keys in Terraform files, `.tfvars` files, or Git.**

## How to run development

Run these commands from the repository root.

### 1. Initialize

```bash
terraform init
```

### 2. Format and validate

```bash
terraform fmt -recursive
terraform validate
```

### 3. Create and review the dev plan

```bash
terraform plan -var-file=envs/dev.tfvars -out=dev.tfplan
```

Review the plan carefully. Confirm that the resources and region are
expected and that the optional EC2 instance remains disabled.

### 4. Apply only dev

```bash
terraform apply dev.tfplan
```

### 5. Inspect outputs

```bash
terraform output
```

Verify the created resources in the AWS Console as well. Save the
command output under `evidence/` as required by the assignment.

> The saved `dev.tfplan` file is local-only and must not be committed to
> Git.

## How to plan staging and production

The assignment requires plans only for these environments. Do **not**
apply either plan.

```bash
terraform plan -var-file=envs/staging.tfvars
terraform plan -var-file=envs/prod.tfvars
```

Inspect the output for the expected environment-specific settings and
any proposed changes. Keep the plan logs in `evidence/`.

## How to destroy development resources

After verifying the dev deployment and collecting evidence, destroy its
resources:

```bash
terraform destroy -var-file=envs/dev.tfvars
```

Read the proposed destruction carefully and confirm when prompted. Then
check that the resources have been removed from AWS and retain the
destroy output in `evidence/destroy-dev.txt`.

If you use the command-line output to capture evidence, for example in
Git Bash:

```bash
terraform destroy -var-file=envs/dev.tfvars 2>&1 | tee evidence/destroy-dev.txt
```

Do not run `destroy` for staging or production.

## Makefile shortcuts

The root `Makefile` provides shortcuts for common commands:

Command Equivalent action

---

`make fmt` `terraform fmt -recursive`
`make validate` Initialize with `-backend=false`, then validate
`make plan-dev` Plan using `envs/dev.tfvars`
`make plan-staging` Plan using `envs/staging.tfvars`
`make plan-prod` Plan using `envs/prod.tfvars`
`make destroy-dev` Destroy using `envs/dev.tfvars`

Run these from the project root. `make destroy-dev` is destructive; use
it only when you intend to remove the dev resources. Make sure GNU Make
is installed and available on your `PATH`.

## GitHub Actions CI

The workflow in `.github/workflows/terraform.yml` runs automatically on
pushes and pull requests. It performs:

1.  Repository checkout.
2.  Terraform CLI setup.
3.  A recursive formatting check (`terraform fmt -check -recursive`).
4.  Initialization without a remote backend
    (`terraform init -backend=false`).
5.  Terraform validation (`terraform validate`).

This is a **CI check only**. It does not apply or destroy infrastructure
and does not require AWS credentials. Check the repository's **Actions**
tab to view workflow results.

## Known limitations

- This is a learning/demo configuration, not a complete production
  application platform.
- Staging and production are plan-only for this assignment; no
  production deployment is performed.
- Using different `.tfvars` files does not automatically isolate
  Terraform state. If the environments are ever deployed separately,
  configure separate state files or a deliberate state-isolation
  strategy before applying them.
- `backend-example.tf` is an example only. Do not enable a remote
  backend without configuring the bucket, region, permissions, and
  state-locking approach first.
- Terraform's `lifecycle.prevent_destroy` is a lifecycle meta-argument
  that must be configured as a literal value, not dynamically from an
  ordinary input variable. The production destroy protection should be
  implemented with a Terraform-valid static lifecycle configuration
  before this project is used to manage real production resources.
- The `$5` budget is a target, not a guarantee. Monitor actual AWS
  usage and remove test resources promptly.
- The project is intentionally limited to the resource types and
  behavior required for this assignment; additional security controls,
  monitoring, and operational procedures would be needed for real
  production use.

---

## Maintainer notes

Before submission, replace `OWNER/REPOSITORY` in the status badge URL at
the top with the actual GitHub owner and repository name. Verify that
all file paths and evidence files listed above exist in your repository
and that the documented commands match the final configuration.
