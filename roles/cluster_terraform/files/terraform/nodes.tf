
variable "node_type" {
  default = "t2.medium"
}

output "metal_k8s_instance_ids" {
  value = ["${aws_instance.nodes.*.id}"]
}

resource "aws_instance" "nodes" {
  ami           = "${data.aws_ami.centos7.id}"
  instance_type = "${var.node_type}"

  subnet_id = "${var.vpc_subnet_id}"
  associate_public_ip_address = "true"

  root_block_device {
    delete_on_termination = "true"
  }

  tags {
    Name = "metal-k8s"
  }
  key_name = "${aws_key_pair.local_ssh_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_http.id}"]
  count = "${var.node_count}"
}

resource "aws_ebs_volume" "nodes" {
  availability_zone = "${element(aws_instance.nodes.*.availability_zone, count.index)}"
  size = 200
  tags {
    Name = "metal_k8s"
  }
  count = "${var.node_count}"
}

resource "aws_volume_attachment" "nodes_lvm" {
  device_name = "/dev/sdf"
  volume_id   = "${element(aws_ebs_volume.nodes.*.id, count.index)}"
  instance_id = "${element(aws_instance.nodes.*.id, count.index)}"
  count = "${var.node_count}"
  force_detach = "true"
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow ssh and http for metal-k8s"

  vpc_id = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
