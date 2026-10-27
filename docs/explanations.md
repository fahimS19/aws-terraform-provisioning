# Terraform Best Practices & Patterns

## 1. Conditional Naming

**Conditional naming uses ternary operators to dynamically name resources based on the environment.** This avoids manual renaming and enforces consistency across staging and production.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = var.environment == "prod" ? "company-prod-data-bucket" : "company-dev-data-bucket"
}
```

---

## 2. `count` vs `for_each`

**Use `count` for simple, identical duplicates or true/false creation. Use `for_each` when creating distinct resources based on a map or set of strings.**

| Feature       | `count`                                                                                      | `for_each`                                                            |
| :------------ | :------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------- |
| **Best For**  | Identical copies or conditional toggles (0 or 1).                                            | Unique configurations (e.g., varying subnets).                        |
| **Data Type** | Whole numbers.                                                                               | Maps or sets of strings.                                              |
| **Risk**      | Deleting an item in the middle of a list shifts indexes and triggers unintended recreations. | Safe. Resources are bound to unique keys rather than ordered indexes. |

---

## 3. Dynamic Blocks

**Dynamic blocks act like `for_each` loops inside a resource to generate repeating nested configuration blocks.** This keeps our code DRY (Don't Repeat Yourself) when dealing with repeating arguments like security group rules or tags.

```hcl
variable "ingress_rules" {
  type    = list(number)
  default = [80, 443, 8080]
}

resource "aws_security_group" "api_sg" {
  name = "api-security-group"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

---

## 4. `.tfvars` Strategy

**Separate your environmental configurations into distinct `.tfvars` files while keeping your core infrastructure logic identical.**

- **`terraform.tfvars`**: Contains global, environment-agnostic variables.
- **`dev.tfvars` / `prod.tfvars`**: Contains environment-specific configurations (e.g., smaller instances for dev, larger for prod).
- **Execution**: Apply them using the var-file flag: `terraform apply -var-file="prod.tfvars"`

---

## 5. Cost Control

**Control infrastructure spend directly through your Terraform architecture and automation pipelines.**

- **Right-Sizing via Variables**: Map instance sizes to environments inside your `.tfvars` so non-production environments use cheaper tiers.
- **Auto-Shutdown Toggles**: Use a conditional `count` to scale down resource counts (like ECS tasks or VM clusters) to `0` outside of business hours.
- **Static Analysis**: Integrate tools like **Infracost** into our CI/CD pipeline to estimate cost impacts before running `terraform apply`.
