variable "name" {
  description = "Base name for VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones to deploy into"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
