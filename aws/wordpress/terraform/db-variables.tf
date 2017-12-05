variable "db_identifier" {
    default     = "wordpress-db"
    description = "Identifier for DB"
}

variable "db_storage" {
    default     = "10"
    description = "Storage size in GB"
}

variable "db_engine" {
    default     = "mysql"
    description = "Engine type, example values mysql, postgres"
}

variable "db_engine_version" {
    default = {
        mysql    = "5.7"
        postgres = "9.6"
    }

    description = "Engine version"
}

variable "db_instance_class" {
    default     = "db.t2.micro"
    description = "Instance class"
}

variable "db_name" {
    description = "Database name"
}

variable "db_username" {
    description = "Database username"
}

variable "db_password" {
    description = "Database password"
}