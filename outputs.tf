output "aws_instance_public_dns" {
  value       = "http://${aws_lb.nginx-alb.dns_name}"
  description = "pubic dns url for the service"
}

output "aws_s3_bucket_arn" {
  value = aws_s3_bucket.s3.arn
  description = "arn of s3 bucket"
}