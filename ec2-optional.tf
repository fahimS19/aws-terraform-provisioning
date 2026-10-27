
resource "aws_instance" "test" {
  count = var.enable_ec2_test_instance ? 1 : 0

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-test-instance-${local.region_suffix}"
    }
  )
}
