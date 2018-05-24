variable "ssh_key_path" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable "node_count" {
  type = "string"
  default = "5"
}

variable "vpc_name" {
  default = ""
}

variable "vpc_subnet_id" {
  default = ""
}

output "vpc" {
  value = "${data.aws_vpc.vpc.id}"
}

resource "aws_key_pair" "local_ssh_key" {
  key_name   = "deployer-key"
  public_key = "${file(var.ssh_key_path)}"
}

data "aws_ami" "centos7" {
  most_recent = true
  filter {
    name   = "description"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA 1804_2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
  owners = ["aws-marketplace"]
}

data "aws_vpc" "default" {
  default = 1
  count = "${var.vpc_name == "" ? 1 : 0}"
}

data "aws_vpc" "custom" {
  count = "${var.vpc_name == "" ? 0 : 1}"
  #id = "${var.vpc_name}"
  filter {
    name = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_vpc" "vpc" {
  id = "${element(concat(data.aws_vpc.default.*.id, data.aws_vpc.custom.*.id), 0)}"
}
