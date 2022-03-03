# Databases
variable "database_instance_type" {
  default = "db.m6g.xlarge"
}
variable "database_name" {
  default = "openreplay"
}
variable "database_user_name" {
  default = "openreplay"
}
variable "database_user_password" {
  description = "postgres user password"
}
variable "database_create_random_password" {
  default = false
}
variable "environment" {
  description = "environment"
  default = "dev"
}
variable "tags" {
  default = {
    Terraform = "true"
    Environment = "dev"
    Service = "OpenReplay"
  }
}



variable "vpc_id" {
  description = "vpc id"
}
variable "vpc_cidr_block" {
  description = "cidr block"
}
variable "database_subnet_group" {
  description = "database subnet group"
}
variable "region" {
  description = "aws region"
}
