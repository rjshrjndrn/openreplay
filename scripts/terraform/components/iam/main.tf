resource "aws_iam_access_key" "s3" {
  user    = aws_iam_user.s3.name
}

resource "aws_iam_user" "s3" {
  name = "openreplay-s3-write-user-${var.environment}"
  path = "/system/"
}

resource "aws_iam_user_policy" "s3_rw" {
  name = "openreplay-write-policy-${var.environment}"
  user = aws_iam_user.s3.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.bucket_name["openreplay-recordings"].bucket_name}",
                "arn:aws:s3:::${var.bucket_name["openreplay-recordings"].bucket_name}/*",
                "arn:aws:s3:::${var.bucket_name["openreplay-assets"].bucket_name}",
                "arn:aws:s3:::${var.bucket_name["openreplay-assets"].bucket_name}/*",
                "arn:aws:s3:::${var.bucket_name["openreplay-sourcemaps"].bucket_name}",
                "arn:aws:s3:::${var.bucket_name["openreplay-sourcemaps"].bucket_name}/*",
            ]
        }
    ]})

}

output "secret" {
  value = aws_iam_access_key.s3.encrypted_secret
}
