variable "public_1_cidr" {
    default     = "10.0.0.0/24"
    description = "Public subnet for ELBs"
}

variable "public_2_cidr" {
    default     = "10.0.1.0/24"
    description = "Public subnet for ELBs"
}

variable "db_1_cidr" {
    default     = "10.0.2.0/24"
    description = "Private subnet for databases"
}

variable "db_2_cidr" {
    default     = "10.0.3.0/24"
    description = "Private subnet for databases"
}

variable "web_1_cidr" {
    default     = "10.0.4.0/24"
    description = "Private subnet for web"
}

variable "web_2_cidr" {
    default     = "10.0.5.0/24"
    description = "Private subnet for web"
}

variable "bastion_cidr" {
    default     = "10.0.6.0/28"
    description = "Public subnet for bastion host"
}

variable "az_1" {
    default     = "us-west-2a"
    description = "Availability zone 1"
}

variable "az_2" {
    default     = "us-west-2b"
    description = "Availability zone 2"
}
