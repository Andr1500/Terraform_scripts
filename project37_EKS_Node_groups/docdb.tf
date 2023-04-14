resource "aws_docdb_subnet_group" "service" {
  name       = "tf-${var.project}"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_docdb_cluster_instance" "service" {
  count              = 1
  identifier         = "tf-${var.project}-${count.index}"
  cluster_identifier = aws_docdb_cluster.service.id
  instance_class     = var.docdb_instance_class
}

resource "aws_docdb_cluster" "service" {
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.service.name
  cluster_identifier              = "tf-${var.project}"
  engine                          = "docdb"
  master_username                 = var.docdb_username
  master_password                 = var.docdb_password
  port                            = 27017
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.service.name
  vpc_security_group_ids          = ["${aws_security_group.public_sg.id}"]
}

resource "aws_docdb_cluster_parameter_group" "service" {
  family = "docdb4.0"
  name   = "tf-${var.project}"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
