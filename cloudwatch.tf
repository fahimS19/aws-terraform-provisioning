
resource "aws_cloudwatch_log_group" "app" {
  for_each = var.enable_cloudwatch_logs ? var.log_groups : {}

  name = "${local.name_prefix}-${each.key}-logs-${local.region_suffix}"

  retention_in_days = each.value

  tags = local.common_tags
}
