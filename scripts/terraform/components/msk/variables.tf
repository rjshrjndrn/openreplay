variable "environment" {
  description = "environment"
}
variable "kafka_version" {
  description = "kafka_version"
  default = "2.8.1"
}
variable "number_of_broker_nodes" {
  description = "number_of_broker_nodes"
}
variable "msk_instance_type" {
  description = "msk_instance_type"
  default = "kafka.m5.xlarge"
}
variable "msk_ebs_volume_size" {
  description = "msk_ebs_volume_size"
  default = "500"
}
variable "msk_client_subnets" {
  description = "msk_client_subnets"
}
variable "tags" {
  description = "tags"
}
variable "msk_vpc_id" {
  description = "vpc id where kakfka is running"
}
variable "msk_vpc_cidr_block" {
  description = "cidr block where kakfka is running"
}
