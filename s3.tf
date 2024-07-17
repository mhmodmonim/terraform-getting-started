# aws_s3_bucket
resource "aws_s3_bucket" "s3" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = merge({
    Name = local.s3_bucket_name
  }, local.common_tags)
}


# aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.root.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3.arn}/alb-logs/*",
    ]
  }

  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3.arn}/alb-logs/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.s3.arn,
    ]
  }
}



#aws_s3_object

resource "aws_s3_object" "website_contents" {
  for_each = local.website_content
  bucket   = aws_s3_bucket.s3.bucket
  key      = each.value
  source   = "${path.root}/${each.value}"

  tags = local.common_tags

}