variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_desired" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
