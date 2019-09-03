environment   = "qa"
cluster_name  = "nclouds"
region        = "us-west-2"

### VPC MODULE
vpc= {
    cidr          = "10.2.0.0/16",
    dns_hostnames = true,
    dns_support   = true,
    tenancy       = "default",
  }
public_subnets  = ["10.2.0.0/24","10.2.1.0/24"]
private_subnets = ["10.2.2.0/24","10.2.3.0/24","10.2.4.0/24"]
#rds_subnets     = ["10.2.5.0/24","10.2.6.0/24"]

### EKS MODULE
worker= {
  instance-type = "t3.xlarge",
  desired-size  = "3",
  min-size      = "2",
  max-size      = "4"
  key_name      = "test"
}
public_domain_name = "shanux.com"