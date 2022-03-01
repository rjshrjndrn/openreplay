locals {
  name = "openreplay-msk-${var.environment}"
  tags = {
    Name: local.name
    Service: "OpenReplay"
  }
}
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "msk security group"
  vpc_id      = var.msk_vpc_id

  # ingress
ingress_with_cidr_blocks = [
  {
      from_port   = 0
      to_port     = 9094
      protocol    = "tcp"
      description = "MSK access from within VPC"
      cidr_blocks = var.msk_vpc_cidr_block
    },
  {
      from_port   = 0
      to_port     = 9092
      protocol    = "tcp"
      description = "MSK access from within VPC"
      cidr_blocks = var.msk_vpc_cidr_block
    },
  {
      from_port   = 0
      to_port     = 2181
      protocol    = "tcp"
      description = "MSK zookeeper access from within VPC"
      cidr_blocks = var.msk_vpc_cidr_block
    },
  {
      from_port   = 0
      to_port     = 2182
      protocol    = "tcp"
      description = "MSK zookeeper access from within VPC"
      cidr_blocks = var.msk_vpc_cidr_block
    },
  ]
  tags = local.tags
}
resource "aws_msk_cluster" "msk" {
  cluster_name = local.name
  kafka_version = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_node_group_info {
    instance_type = var.msk_instance_type
    ebs_volume_size = var.msk_ebs_volume_size
    client_subnets = var.msk_client_subnets
    security_groups =[module.security_group.security_group_id] 
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  tags = merge(local.tags, var.tags)
}
