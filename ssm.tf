
resource "aws_ssm_parameter" "app" {
  for_each = var.enable_ssm_parameters ? var.ssm_parameters : {}

  name = "${local.name_prefix}-${each.key}-logs-${local.region_suffix}"
  type = "String"

  value = each.value

  tags = local.common_tags
}
