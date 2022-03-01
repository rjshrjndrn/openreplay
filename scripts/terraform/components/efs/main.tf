locals {
  name = "openreplay-postgres-${var.environment}"
  tags = var.tags
}

# Creating EFS file system
resource "aws_efs_file_system" "efs" {
creation_token = "openreplay-efs"
lifecycle_policy {
  transition_to_ia = "AFTER_30_DAYS"
}

tags = {
  Name = "openreplay-efs"
  }
}

# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
  count = length(var.subnet_id)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.subnet_id[count.index]
  security_groups = [module.security_group.security_group_id]
  depends_on = [
    var.subnet_id,
  ]
}

################################################################################
# Supporting Resources
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "PostgreSQL security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 2049
      protocol    = "tcp"
      description = "efs access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]

  tags = merge(local.tags, var.tags)
}
