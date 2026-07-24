resource "aws_dynamodb_table" "my_app_table" {
  count = var.dynamodb_table_count
  name         = "${var.my_environment}-${var.dynamodb_table_name}-${count.index + 1}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.my_environment}-${var.dynamodb_table_name}-${count.index + 1}"
    Environment = var.my_environment
  }
}
