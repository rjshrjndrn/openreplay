output "aws_iam_access_key" {
  value = aws_iam_access_key.s3.id
}
output "aws_iam_access_secret" {
  value = aws_iam_access_key.s3.secret
}
