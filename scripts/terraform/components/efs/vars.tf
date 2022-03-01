variable "tags" {
 description = "tags" 
}
variable "subnet_id" {
  description = "subnet_id"
}
variable "vpc_id" {
  description = "vpc_id"
}
variable "vpc_cidr_block" {
  description = "vpc_cidr_block"
}
variable "environment" {
  description = "environment"
  default = "dev"
}
