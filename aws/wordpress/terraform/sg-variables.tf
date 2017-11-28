variable "cidr_blocks" {
    default     = "0.0.0.0/0"
    description = "CIDR for sg"
}

variable "db_sg_name" {
    default     = "rds_sg"
    description = "Tag name for sg"
}