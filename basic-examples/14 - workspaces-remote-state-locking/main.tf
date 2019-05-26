provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket         = "aws-terraform-596631674148-us-east-1-remote-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-terraform-596631674148-us-east-1-remote-state"
  }
}

locals {
  env = "${terraform.workspace}"
}

resource "aws_instance" "web" {
  ami           = "${lookup(var.ami, local.env)}"
  instance_type = "${lookup(var.type, local.env)}"

  tags = {
    Name = "My web server ${local.env}"
    Env  = "${local.env}"
  }
}