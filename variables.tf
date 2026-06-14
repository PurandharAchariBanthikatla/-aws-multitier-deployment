variable "name_prefix" {
  description = "Prefix used for naming resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public (web) subnet"
  type        = string
}

variable "private_app_subnet_cidr" {
  description = "CIDR block for the private app subnet"
  type        = string
}

variable "private_db_subnet_cidr" {
  description = "CIDR block for the first private db subnet"
  type        = string
}

variable "private_db_subnet_cidr_2" {
  description = "CIDR block for the second private db subnet (different AZ)"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use (at least 2 required)"
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
