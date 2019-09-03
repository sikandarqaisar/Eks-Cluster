variable "region" {
  type = "string"
  description = "aws region"
}

variable "environment" {}

variable "cluster_name" {}

### VPC MODULE
variable "vpc" {
   type = "map"
}

variable "public_subnets" {
   type = "list"
}

variable "private_subnets" {
   type = "list"
}

variable "rds_subnets" {
  type = "list"
  default = []
}

### EKS MODULE
variable "worker" {
  type = "map"
}

variable "public_domain_name" {
  type = "string"
  description = "Public domain for the public services"
  default = "sikandarTest.com"
}