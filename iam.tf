
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "app_access" {
  dynamic "statement" {
    for_each = var.enable_ssm_parameters ? [1] : []

    content {
      sid    = "ReadApplicationParameters"
      effect = "Allow"

      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]

      resources = [
        "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.enable_dynamodb ? [1] : []

    content {
      sid    = "AccessConfigurationTable"
      effect = "Allow"

      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]

      resources = [
        aws_dynamodb_table.config[0].arn
      ]
    }
  }
}


resource "aws_iam_role" "app" {
  count = var.enable_iam_role ? 1 : 0

  name               = "${local.name_prefix}-app-role-${local.region_suffix}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.common_tags
}


resource "aws_iam_policy" "app_access" {
  count = var.enable_iam_role ? 1 : 0

  name = "${local.name_prefix}-app-policy-${local.region_suffix}"

  policy = data.aws_iam_policy_document.app_access.json

  tags = local.common_tags
}


resource "aws_iam_role_policy_attachment" "app_access" {
  count = var.enable_iam_role ? 1 : 0

  role       = aws_iam_role.app[0].name
  policy_arn = aws_iam_policy.app_access[0].arn
}
