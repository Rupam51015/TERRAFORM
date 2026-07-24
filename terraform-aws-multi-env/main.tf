locals {
  env = {
    dev = {
      instance_count = 2
      bucket_count = 1
      table_count = 1
    }
    stg = {
      instance_count = 3
      bucket_count = 1
      table_count = 1
    }
    prod = {
      instance_count = 4
      bucket_count = 1
      table_count = 2
    }
  }
}

module "ec2" {
  source = "./modules/ec2"
  my_environment = terraform.workspace
  ec2_count = local.env[terraform.workspace].instance_count
}

module "s3" {
  source = "./modules/s3"
  my_environment = terraform.workspace
  s3_bucket_count = local.env[terraform.workspace].bucket_count
}

module "dynamodb" {
  source = "./modules/dynamodb"
  my_environment = terraform.workspace
  dynamodb_table_count = local.env[terraform.workspace].table_count
}