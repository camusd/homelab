resource "aws_s3_bucket" "state" {
  bucket = "wordpress-terraform-state-dev"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name = "wordpress-terraform-state-dev"
  }
}

resource "aws_s3_bucket" "web_backup" {
  bucket = "wordpress-web-backup-dev"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name = "wordpress-web-backup-dev"
  }
}
