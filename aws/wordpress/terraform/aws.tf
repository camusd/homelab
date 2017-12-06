provider "aws" {
   access_key = "${var.aws_access_key}"
   secret_key = "${var.aws_secret_key}"
   region     = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket  = "wordpress-terraform-state-dev"
    key     = "state/wordpress.tfstate"
    region  = "us-west-2"
  }
}

data "terraform_remote_state" "state" {
  backend = "s3"

  config {
    bucket = "wordpress-terraform-state-dev"
    key    = "state/wordpress.tfstate"
    region = "us-west-2"
  }
}
