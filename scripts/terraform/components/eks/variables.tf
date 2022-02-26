variable "vpc_id" {
  description = "vpc id"
}
variable "private_subnets" {
  description = "private subnets"
}
variable "eks_instance_type" {
  description = "eks instance type"
  default = "m5.xlarge"
}
variable "eks_instance_min_count" {
  description = "minmum eks node count"
  default = "4"
}
variable "eks_instance_max_count" {
  description = "maximum eks node count"
  default = "10"
}
variable "tags" { }
variable "eks_cluster_version" {
  default = "1.21"
  description = "kubernetes version"
}
variable "eks_name" {
  default = "openreplay-eks"
  description = "eks name"
}
variable "region" {
  description = "aws region"
}
