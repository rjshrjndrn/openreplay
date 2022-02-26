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
