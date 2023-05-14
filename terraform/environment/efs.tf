    module "efs" {
      source                    = "../modules/efs"
      efs_name                      = var.efs_name
      creation_token            = var.efs_name
      region                    = var.region
      vpc_id                    = var.vpc_id
      subnets                   = var.private_subnet
      vpc_cidr_range            = var.vpc_cidr_range
    }