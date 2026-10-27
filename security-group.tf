
data "aws_vpc" "default" {
  default = true
}


resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg-${local.region_suffix}"
  description = "Security group for the Terraform assignment"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks

    content {
      description = "HTTP access from an approved CIDR"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
