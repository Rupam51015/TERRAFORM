variable "my_environment" {
  description = "Deployment environment (dev, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.my_environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}

variable "s3_bucket_count" {
  description = "This variable holds the count of s3 buckets"
  type = number
}

variable "s3_bucket_name" {
  description = "Name of the s3 bucker"
  type = string
  default = "my-rdn-bucket"
}