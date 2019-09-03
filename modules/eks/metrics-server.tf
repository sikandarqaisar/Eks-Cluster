# @read https://eksworkshop.com/scaling/deploy_hpa/
data "template_file" "metrics_server" {
  template = "${file("${path.module}/templates/metrics-server.yaml.tpl")}"
  vars {
    metrics_server_version = "${var.metrics_server_version}"
  }
}
resource "local_file" "metrics_server" {
  content  = "${data.template_file.metrics_server.rendered}"
  filename = "dist/metrics-server_${aws_eks_cluster.k8s.name}.yaml"
  depends_on = ["null_resource.clean_dist"]
}
