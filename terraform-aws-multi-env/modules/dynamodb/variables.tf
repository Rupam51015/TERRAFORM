variable "my_environment" {
  description = "Deployment environment (dev, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.my_environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}

variable "dynamodb_table_count" {
  description = "This variable holds the count of dynamodb table"
  type = number
}

variable "dynamodb_table_name" {
  description = "Dynamodb table name"
  type = string
  default = "my-rdn-table"
}