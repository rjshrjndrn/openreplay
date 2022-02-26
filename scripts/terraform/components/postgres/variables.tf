# Databases
variable "database_instance_type" {
  default = "db.m5.xlarge"
}
variable "database_name" {
  default = "openreplay"
}
variable "database_user_name" {
  default = "openreplay"
}
variable "database_user_password" {
  description = "Postgres password"
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
