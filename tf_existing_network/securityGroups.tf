# Load Balancer Security Group

resource "aws_security_group" "looker_lb" {
  name        = "${var.prefix}_lb"
  description = "Security group for access to looker load balancer"
  vpc_id      = var.vpc_id

  # This needs to be expanded to all the ip ranges.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = split(",", var.ingress_ips)
    description = var.ingress_ip_description
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.prefix}_lb"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}

# Instance Security Group
resource "aws_security_group" "looker_instance" {
  name        = "${var.prefix}_instance"
  description = "Security group for access to looker server"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_instance.id}"]
  }

  ingress {
    from_port       = var.node_listener_port
    to_port         = var.node_listener_port
    protocol        = "tcp"
    security_groups = ["${aws_security_group.looker_lb.id}"]
  }

  ingress {
    from_port       = var.api_listener_port
    to_port         = var.api_listener_port
    protocol        = "tcp"
    security_groups = ["${aws_security_group.looker_lb.id}"]
  }

  ingress {
    from_port   = var.node_to_node_port
    to_port     = var.node_to_node_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = var.queue_broker_port
    to_port     = var.queue_broker_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.prefix}_instance"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}

# RDS Security Group
resource "aws_security_group" "looker_rds" {
  name        = "${var.prefix}_rds"
  description = "Security group for access to rds server for looker"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.looker_instance.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.prefix}_rds"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion_instance" {
  name        = "${var.prefix}_bastion"
  description = "Security group for bastion access to looker server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = split(",", var.ingress_ips)
    description = var.ingress_ip_description
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.prefix}_bastion"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}

# EFS Security Group
resource "aws_security_group" "looker_efs" {
  name        = "${var.prefix}_efs"
  description = "Security group for access to efs mounts for looker"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.looker_instance.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.prefix}_efs"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact_email}"
    customer      = "${var.tag_customer}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
  }
}
