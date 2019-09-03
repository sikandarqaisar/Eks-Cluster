variable "vpc" {
  type        = "map"
  description = "Map of AWS VPC settings"

  default = {
    cidr            = "10.101.0.0/16"
    dns_hostnames   = true
    dns_support     = true
    tenancy         = "default"
  }
}

variable "environment" {
  type    = "string"
  default = "dev"
}

variable "cluster_name" {
  type    = "string"
  default = "unitq"
}

variable "public_subnets" {
  type        = "list"
  description = "List of CIDR assignments"
  default     = ["10.101.0.0/24","10.101.1.0/24"]
}

variable "private_subnets" {
  type        = "list"
  description = "List CIDR assignments"
  default     = ["10.101.2.0/24","10.101.3.0/24"] 
}

variable "rds_subnets" {
  type        = "list"
  description = "List CIDR assignments for RDS"
  default     = []
}
variable "elasticache_subnets" {
  type        = "list"
  description = "List CIDR assignments for elasticache"
  default     = []
}
variable "vpc_to_connect" {
  type = "map"
  description = "Id and cidr [vpc_id,vpc_cidr] of the vpcs to create the peering connection"
  default = {}
}