terraform {
  required_version = ">= 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }
  backend "s3" {
    bucket = "my-remote-backend-state-bucket"
    key    = "terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "my-remote-backend-lock-table"
  }
}

provider "aws" {
  region = "us-west-1"
}
