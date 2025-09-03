variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-northeast-2"
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "my_website" {
  bucket = "woogie-s3" # 고유한 버킷 이름으로 변경
  tags = {
    Name = "Woogie Website Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "my_website_config" {
  bucket = aws_s3_bucket.my_website.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_website.bucket
  key          = "index.html"
  source       = "../index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "my_website_public_access_block" {
  bucket                  = aws_s3_bucket.my_website.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "my_website_policy" {
  depends_on = [aws_s3_bucket_public_access_block.my_website_public_access_block]
  bucket     = aws_s3_bucket.my_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_website.arn}/*"
      }
    ]
  })
}

output "website_url" {
  value = "http://${aws_s3_bucket.my_website.bucket}.s3-website.${var.region}.amazonaws.com"
}
