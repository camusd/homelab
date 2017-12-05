variable "web_ami_id" {
  default = "ami-15e73d6d"
  description = "Web ami"
}

variable "aws_public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_key_name" {
  description = "Desired name of AWS key pair"
}

variable "git_repo" {
  description = "The repo that contains the wordpress app"
}

variable "wp_auth_key" {
  description = "Wordpress auth key"
}

variable "wp_secure_auth_key" {
  description = "Wordpress secure auth key"
}

variable "wp_logged_in_key" {
  description = "Wordpress logged in key"
}

variable "wp_nonce_key" {
  description = "Wordpress nonce key"
}

variable "wp_auth_salt" {
  description = "Wordpress auth salt"
}

variable "wp_secure_auth_salt" {
  description = "Wordpress secure auth salt"
}

variable "wp_logged_in_salt" {
  description = "Wordpress logged in salt"
}

variable "wp_nonce_salt" {
  description = "Wordpress nonce salt"
}