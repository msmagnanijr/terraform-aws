#terraform taint aws_s3_bucket_object.object
#terraform untaint aws_s3_bucket_object.object


provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-openshift"
  acl    = "private"

  tags = {
    Name        = "My bucket Openshift"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.b.id}"
  key    = "ocp.txt"
  source = "arquivo.txt"
  etag   = "${md5(file("arquivo.txt"))}"
}

output "bucket" {
  value = "${aws_s3_bucket.b.id}"
}

output "etag" {
  value = "${aws_s3_bucket_object.object.etag}"
}