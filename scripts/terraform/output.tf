output "postgres_endpoint" {
  value = module.database.db_instance_endpoint
  description = "postgres_endpoint"
}

output "msk_endpoint" {
  value = module.msk.msk_endpoint
  description = "msk conncection endpoint"
}

output "efs_id" {
  value = module.efs.aws_efs_file_system_id
  description = "efs file system id"
}

output "s3_buckets" {
  description = "s3 buckets to store assets"
  value = { for k,v in module.s3 : k => v }
}

output "iam_key" {
  description = "IAM user Access key"
  value = module.iam.aws_iam_access_key
}
