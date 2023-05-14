resource "aws_security_group" "this" {
  name        = "${var.name}"
  description = "${var.description}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_security_group_rule" "ingress_rules" {
  count = "${length(var.allowed_cidrs)}"

  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  cidr_blocks      = ["${lookup(var.allowed_cidrs[count.index], "cidr")}"]
  description      = "${lookup(var.allowed_cidrs[count.index], "description")}"

  from_port = "${lookup(var.allowed_cidrs[count.index], "from_port")}"
  to_port   = "${lookup(var.allowed_cidrs[count.index], "to_port")}"
  protocol  = "${lookup(var.allowed_cidrs[count.index], "protocol")}"
}

resource "aws_security_group_rule" "allowed_groups" {
  count = "${length(var.allowed_groups)}"

  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"

  source_security_group_id = "${lookup(var.allowed_groups[count.index], "source_security_group_id")}"
  description              = "${lookup(var.allowed_groups[count.index], "description", "Ingress Rule")}"

  from_port = "${lookup(var.allowed_groups[count.index], "from_port")}"
  to_port   = "${lookup(var.allowed_groups[count.index], "to_port")}"
  protocol  = "${lookup(var.allowed_groups[count.index], "protocol")}"
}

# Security group rules with "self", but without "cidr_blocks" and "source_security_group_id"
resource "aws_security_group_rule" "allowed_self" {
  count = "${length(var.allowed_self)}"

  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"

  self             = true
  description      = "${lookup(var.allowed_self[count.index], "description", "Ingress Rule")}"

  from_port = "${lookup(var.allowed_self[count.index], "from_port")}"
  to_port   = "${lookup(var.allowed_self[count.index], "to_port")}"
  protocol  = "${lookup(var.allowed_self[count.index], "protocol")}"
}

resource "aws_security_group_rule" "egress_rules" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "egress"

  cidr_blocks      = ["0.0.0.0/0"]

  from_port = "0"
  to_port   = "0"
  protocol  = "-1"
}
