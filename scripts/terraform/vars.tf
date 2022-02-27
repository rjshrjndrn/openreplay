###########
# Optional
###########
variable "cidr" {
  default = "10.0.0.0/16"
}
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "database_subnets" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_user_name" {
  description = "username for postgres"
}
variable "database_user_password" {
  description = "master password for postgres"
}

variable "region" {
  description = "region to run the tf against"
}

variable "environment" {
  default = "dev"
}
variable "tags" {
  default = {
    Terraform = "true"
    Environment = "dev"
    Service = "OpenReplay"
  }
}


## Output

output "reg" {
  value = "${data.aws_availability_zones.available.names}"
}
