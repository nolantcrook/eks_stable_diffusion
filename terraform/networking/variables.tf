
variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "route53_zone_id_secret_arn" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "alb_logs_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for ALB access logs"
}

# Removing unused variables:
# - single_az_dev
# - node_asg_name
