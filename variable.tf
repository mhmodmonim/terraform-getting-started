variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}
variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
  sensitive   = true
}
variable "aws_region" {
  type        = string
  description = "AWS region to use for resources"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "holds the cidr range for vpc"
  default     = "10.0.0.0/16"
}
variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "value of dns enabling hostnames"
  default     = true
}

variable "public_subnets_cidr_block" {
  type        = list(string)
  description = "subnets (public) cidr block"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}


variable "vpc_public_subnets_count" {
  type        = number
  description = "the number of public subnets to be created"
  default     = 2
}

variable "subnet_public_ip_on_launch" {
  type        = bool
  description = "value of enabling public ip on launch instance"
  default     = true
}

variable "ec2_instance_type" {
  type        = string
  description = "type of ec2 instance"
  default     = "t3.micro"

}

variable "instance_count" {
  type        = number
  description = "the number of ec2 instances to be created"
  default     = 2
}

variable "company" {
  type        = string
  description = "Company name for each resource"
  default     = "THIQAH"
}
variable "project" {
  type        = string
  description = "Company name for each resource"

}
variable "billing_code" {
  type        = string
  description = "Company name for each resource"
}