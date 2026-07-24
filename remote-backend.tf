resource "aws_s3_bucket" "my_s3" {
  bucket = "my-remote-backend-state-bucket"
# s3 bucket to handel terraform state file
  tags = {
    Name = "my-remote-backend-state-bucket"
  }
}

resource "aws_dynamodb_table" "my-dynamodb-table" {
  name           = "my-remote-backend-lock-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}