provider "aws" {
    region = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "woogie-s3"
}

#s3 버저닝 -> 오래된 상태 파일도 저장
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

#s3 암호화: SSE(서버 측 암호화)
resource "aws_s3_bucket_server_side_encryption_configuration" "default"{
    bucket = aws_s3_bucket.terraform_state.id

    rule{
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

# 공개 액세스 차단
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

#DynamoDB 생성 
resource "aws_dynamodb_table" "terraform_lock" {
    name = "woogie-dynamodb"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}