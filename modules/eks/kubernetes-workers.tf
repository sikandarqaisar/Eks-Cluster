# this will create K8s cluster worker and will also create
# all the necessary IAM roles required by K8s worker nodes

# create an IAM role that will be used by the K8s worker
resource "aws_iam_role" "eks_worker_role" {
  name = "eks_worker_role_k8s_${aws_eks_cluster.k8s.name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Kube2iam policy 
resource "aws_iam_role_policy" "kube2iam-policy" {
  depends_on = ["aws_iam_role.eks_worker_role"]
  name = "terraform_eks_${aws_eks_cluster.k8s.name}_kube2iam_policy"
  role = "${aws_iam_role.eks_worker_role.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    }
  ]
}
EOF
}
# lets start assigning worker node policies to the role
resource "aws_iam_role_policy_attachment" "eks-WorkerPolicies" {
  count      = "${length(var.worker_node_policies)}"
  policy_arn = "arn:aws:iam::aws:policy/${var.worker_node_policies[count.index]}"
  role       = "${aws_iam_role.eks_worker_role.name}"
}

resource "aws_iam_instance_profile" "eks-worker-instance-profile" {
  name = "eks_instance_profile_${aws_eks_cluster.k8s.name}"
  role = "${aws_iam_role.eks_worker_role.name}"
}

resource "aws_security_group" "k8s_worker_security_group" {
  name        = "k8s_worker_sg_${aws_eks_cluster.k8s.name}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${
    map(
    "kubernetes.io/cluster/${aws_eks_cluster.k8s.name}" ,"owned"
    )
  }"
}

resource "aws_security_group_rule" "k8s-worker-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.k8s_worker_security_group.id}"
  source_security_group_id = "${aws_security_group.k8s_worker_security_group.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "k8s-worker-ingress-ssh" {
  count                    = "${var.vpn_sg != "" ? 1 : 0}"
  description              = "Allow vpn to connect over ssh "
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.k8s_worker_security_group.id}"
  source_security_group_id = "${var.vpn_sg}"
  to_port                  = 22
  type                     = "ingress"
}


# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.k8s_version}-*"]
  }
  most_recent = true
}
#https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh
locals {
  worker_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${aws_eks_cluster.k8s.name} --kubelet-extra-args '--node-labels=kubelet.kubernetes.io/role=agent'
# DataDog configuration
DD_API_KEY=${var.datadog_key} bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
echo "tags: ${aws_eks_cluster.k8s.name}_worker" >> /etc/datadog-agent/datadog.yaml
usermod -a -G docker dd-agent
initctl restart datadog-agent
USERDATA
}

# AutoScaling Launch Configuration that uses all our prerequisite resources to define how to create EC2 instances using them.
resource "aws_launch_configuration" "worker_node" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.eks-worker-instance-profile.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  key_name                    = "${var.worker["key_name"]}"
  instance_type               = "${var.worker["instance-type"]}"
  name_prefix                 = "${aws_eks_cluster.k8s.name}_eks_worker_launch_conf"
  security_groups             = ["${aws_security_group.k8s_worker_security_group.id}"]
  user_data_base64            = "${base64encode(local.worker_node_userdata)}"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = ["aws_security_group.k8s_worker_security_group"]
}

# Create an AutoScaling Group that actually launches EC2 instances based on the AutoScaling Launch Configuration.
resource "aws_autoscaling_group" "k8s-worker-auto-scale" {
  desired_capacity     = "${var.worker["desired-size"]}"
  launch_configuration = "${aws_launch_configuration.worker_node.id}"
  max_size             = "${var.worker["max-size"]}"
  min_size             = "${var.worker["min-size"]}"
  name                 = "${aws_eks_cluster.k8s.name}_eks_auto_scaling_group"
  vpc_zone_identifier  = ["${var.private_subnets}"]
  depends_on           = ["aws_launch_configuration.worker_node","aws_security_group.k8s_worker_security_group"]
  lifecycle {
        ignore_changes = ["desired_capacity"]
  }
   tag {
    key                 = "kubernetes.io/cluster-autoscaler/${aws_eks_cluster.k8s.name}"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  } 
  tag {
    key                 = "Name"
    value               = "${aws_eks_cluster.k8s.name}_worker"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.k8s.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

data "template_file" "configmap" {
  template = "${file("${path.module}/templates/configmap.yaml.tpl")}"
  vars {
    workers_role = "${aws_iam_role.eks_worker_role.arn}"
  }
}
resource "local_file" "configmap" {
  content  = "${data.template_file.configmap.rendered}"
  filename = "dist/1.configmap_${aws_eks_cluster.k8s.name}.yaml"
  depends_on = ["null_resource.clean_dist"]
}

