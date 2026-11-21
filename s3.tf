resource "aws_s3_bucket" "mi_bucket" {
  bucket = "tecsup-bucket-juan-2026"

  tags = {
    Name        = "Bucket-Lab-Terraform"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "mi_bucket_versioning" {
  bucket = aws_s3_bucket.mi_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mi_bucket_encryption" {
  bucket = aws_s3_bucket.mi_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
