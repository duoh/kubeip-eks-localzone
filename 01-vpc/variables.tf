variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "lzs" {
  type = list(string)
}
