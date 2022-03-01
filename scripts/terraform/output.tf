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
