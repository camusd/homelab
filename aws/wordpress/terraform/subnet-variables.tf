variable "subnet_1_cidr" {
    default     = "10.0.0.0/24"
    description = "Subnet 1"
}

variable "subnet_2_cidr" {
    default     = "10.0.1.0/24"
    description = "Subnet 2"
}

variable "subnet_3_cidr" {
    default     = "10.0.2.0/24"
    description = "Subnet 3"
}

variable "subnet_4_cidr" {
    default     = "10.0.3.0/24"
    description = "Subnet 4"
}

variable "az_1" {
    default     = "us-west-2a"
    description = "Availability zone 1"
}

variable "az_2" {
    default     = "us-west-2b"
    description = "Availability zone 2"
}