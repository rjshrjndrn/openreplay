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

resource "aws_s3_bucket_policy" "s3policy" {
  # Create policy only on public bucket
  count = var.bucket_acl == "public-read" ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket
  policy = jsonencode({
        "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        }
    ]})
}
