# @read https://docs.aws.amazon.com/es_es/eks/latest/userguide/dashboard-tutorial.html
data "template_file" "dashboard" {
  template = "${file("${path.module}/templates/dashboard.yaml.tpl")}"
  vars {
    dashboard_version = "${var.dashboard_version}"
  }
}
resource "local_file" "dashboard" {
  content  = "${data.template_file.dashboard.rendered}"
  filename = "dist/dashboard_${aws_eks_cluster.k8s.name}.yaml"
  depends_on = ["null_resource.clean_dist"]
}
