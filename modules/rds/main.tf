resource "aws_db_instance" "db" {
  identifier                = "${var.environment}-test",
  allocated_storage         = 10,
  storage_type              = "gp2",
  engine                    = "mysql",
  engine_version            = "8.0.11",
  instance_class            = "db.t2.micro",
  multi_az                  = false,
  storage_encrypted         = false,
  backup_retention_period   = 1,
  password                  = "${data.aws_ssm_parameter.db_password.value}",
  username                  = "user",
  vpc_security_group_ids    = ["${var.db_security_groups_id}"]
  db_subnet_group_name      = "${var.db_subnet_group}"
  final_snapshot_identifier = "${var.environment}-${var.cluster_name}-test-${uuid()}"
//  parameter_group_name      = "utf-8-encoding"
  lifecycle {
    ignore_changes = ["final_snapshot_identifier"] 
  }
}

#
# RDS passwords
#
data "aws_ssm_parameter" "db_password" {
  name = "${var.param_prefix}/${var.environment}/test-password"
}
locals{
  passwords ={
    db1 = "${data.aws_ssm_parameter.db1_password.value}"
  }
}
#
# AWS Security Group for RDS
#
resource "aws_security_group" "rds" {
  name   = "${var.environment}_${var.cluster_name}_rds_sg"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

