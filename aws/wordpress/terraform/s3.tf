resource "aws_s3_bucket" "state" {
  bucket = "wordpress-terraform-state-dev"
  acl    = "private"

  versioning {
    enabled = true
  }
}
