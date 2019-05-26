provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "aws-terraform-remote-state-dev"
    key    = "ec2/ec2.tfstate"
    region = "sa-east-1"
  }
}

locals {
  conn_type    = "ssh"
  conn_user    = "ec2-user"
  conn_timeout = "10m"
  conn_key = "${file("~/Downloads/mmagnani.pem")}"
}

resource "aws_instance" "web" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name      = "mmagnani"

  provisioner "file" {
    source      = "2019-05-23.log"
    destination = "/tmp/file.log"

    connection {
      type        = "${local.conn_type}"
      user        = "${local.conn_user}"
      timeout     = "${local.conn_timeout}"
      private_key = "${local.conn_key}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "echo \"[UPDATING THE SYSTEM]\"",
      "sudo yum update -y",
      "echo \"[INSTALLING HTTPD]\"",
      "sudo yum install -y httpd",
      "echo \"[STARTING HTTPD]\"",
      "sudo service httpd start",
      "sudo chkconfig httpd on",
      "echo \"[FINISHING]\"",
      "sleep 20",
    ]

    connection {
      type        = "${local.conn_type}"
      user        = "${local.conn_user}"
      timeout     = "${local.conn_timeout}"
      private_key = "${local.conn_key}"
    }
  }
}

resource "null_resource" "null" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.id}:${aws_instance.web.public_ip} >> public_ips.txt"
  }
}

resource "tls_private_key" "pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = "mmagnani-${var.env}"
  public_key = "${tls_private_key.pkey.public_key_openssh}"
}