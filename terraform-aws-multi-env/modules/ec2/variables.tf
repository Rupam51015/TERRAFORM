variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "us-west-1"
}

variable "my_ec2" {
  description = "My ec2 instance name"
  type = string
  default = "terra-automate-server"
}

variable "ec2_volume_size" {
  description = "My ec2 instance volube size"
  default = 8
}

variable "ec2_volume_type" {
  description = "My ec2 instance volume type"
  type = string
  default = "gp3"
}

variable "ec2_count" {
  description = "Instance count"
  type = number
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be one of: t2.micro, t2.small, t2.medium, t3.micro, t3.small, t3.medium."
  }
}

variable "my_environment" {
  description = "Deployment environment (dev, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.my_environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}
