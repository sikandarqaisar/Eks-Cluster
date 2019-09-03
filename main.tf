module "vpc" {
  source          = "modules/vpc"
  environment     = "${var.environment}"
  vpc             = "${var.vpc}"
  cluster_name    = "${var.cluster_name}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
  rds_subnets     = "${var.rds_subnets}"
}

module "eks" {
  source             = "modules/eks"
  environment        = "${var.environment}"
  cluster_name       = "${var.cluster_name}"
  worker             = "${var.worker}"
  vpc_id             = "${module.vpc.vpc_id}"
  private_subnets    = "${module.vpc.private_subnets_ids}"
  public_subnets     = "${module.vpc.public_subnets_ids}"
  public_domain_name = "${var.public_domain_name}"
}