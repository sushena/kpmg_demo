
variable "aws_profile" {
  description = "Specify IAM Profile to use"
  type        = string
  default     = "learn01"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "project" {
  description = "Project (e.g. `Internal or External or Customer/Project Name etc`)"
  type        = string
  default     = "kpmg"
}

variable "env" {
  type        = string
  default     = "stage"
  description = "Environment, e.g. 'production', 'staging'"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "Public Subnet CIDR "
  type        = list(any)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vpc_private_subnets" {
  description = "Private Subnet CIDR "
  type        = list(any)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_database_subnets" {
  description = "Database Subnet CIDR "
  type        = list(any)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}
