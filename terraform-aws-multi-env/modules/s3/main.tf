resource "aws_s3_bucket" "testbucket" {
  count = var.s3_bucket_count
  bucket = "${var.my_environment}-${var.s3_bucket_name}-${count.index + 1}"

  tags = {
    Name = "${var.my_environment}-${var.s3_bucket_name}-${count.index + 1}"
    Environment = var.my_environment
  }
}