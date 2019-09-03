variable "environment" {
  type    = "string"
  default = "dev"
}

variable "cluster_name" {
  type    = "string"
  default = "nclouds"
}

# see https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html for the ami for each aws-region
variable "k8s_version" {
  type = "string"
  description = "k8s version"
  default = "1.11"
}
variable "autoscaler_version" {
  type = "string"
  default= "v1.3.7"
}
variable "external_dns_version" {
  type = "string"
  description = "version of external dns pod"
  default = "v0.5.11"
}
variable "kube2iam_version" {
  type = "string"
  description = "version of kube2iam daemon"
  default = "0.10.4"
}
variable "dashboard_version" {
  type = "string"
  description = "version of the dashboard"
  default = "v1.10.1"
}
variable "metrics_server_version" {
  type = "string"
  description = "variable of metrics server, needed for hpa"
  default = "v0.3.1"
}
variable "private_domain_name" {
  type = "string"
  description = "Private domain for the services"
  default = ""
}
variable "public_domain_name" {
  type = "string"
  description = "Public domain for the public services"
  default = "shanux.com"
}
variable "worker" {
  type    = "map"
  description = "Map of EKS workers settings"
  default = {
    instance-type = "t3.large"
    desired-size  = "2"
    min-size      = "2"
    max-size      = "4"
    key_name      = "test"
  }
}
variable "datadog_key" {
  type = "string"
  description = "API Key of the datadog agent"
  default = ""
}

variable "vpc_id" {
  type = "string"
  description = "Id of the vpc where the cluster will be deploy"
}
variable "vpn_sg" {
  type = "string"
  description = "Security group of the vpn to allow connections over ssh"
  default = ""
}

variable "private_subnets" {
  type = "list"
  description = "list of private subnets where the cluster will be deploy"
}
variable "public_subnets" {
  type = "list"
  description = "list of private subnets where the cluster will be deploy"
}

variable "worker_node_policies" {
  type = "list"
  default = [
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
    "CloudWatchFullAccess"]
}
variable "cluster_policies" {
  type = "list"
  default = [
    "AmazonEKSClusterPolicy",
    "AmazonEKSServicePolicy"
  ]
}