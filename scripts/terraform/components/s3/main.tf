resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
}
resource "aws_s3_bucket_acl" "acl" {
  acl = var.bucket_acl
  bucket = aws_s3_bucket.bucket.id
}
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.bucket.id
  cors_rule {
         allowed_headers = [ "*"   ]
         allowed_methods = [ "GET" ]
         allowed_origins = [ "*"   ]
         expose_headers  = []
  }
}
