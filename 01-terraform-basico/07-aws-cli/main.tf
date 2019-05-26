resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-openshift"
  acl    = "private"

  tags = {
    Name        = "Openshift bucket"
    Environment = "Dev"
  }
}