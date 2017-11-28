resource "aws_instance" "web" {
   ami           = "ami-bf4193c7"
   instance_type = "t2.micro"
}

