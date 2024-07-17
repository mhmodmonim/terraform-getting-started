
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# INSTANCES #
resource "aws_instance" "nginx_instances" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public_subnets[(count.index % var.instance_count)].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-nginx-${count.index}"
  })
  iam_instance_profile = aws_iam_instance_profile.nginx_profile.name
  depends_on           = [aws_iam_role_policy.allow_s3_all]
  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    aws_s3_bucket_name = aws_s3_bucket.s3.id
  })

}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-role"
  })
}

# aws_iam_role_policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.s3_bucket_name}",
          "arn:aws:s3:::${local.s3_bucket_name}/*"
        ]
      },
    ]
  })

}

# aws_iam_instance_profile

resource "aws_iam_instance_profile" "nginx_profile" {
  role = aws_iam_role.allow_nginx_s3.name
  name = "nginx_profile"
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-ec2-profile"
  })
}