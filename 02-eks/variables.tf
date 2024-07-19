variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets_local_zone" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubeip_role_name" {
  type = string
}

variable "kubeip_sa_name" {
  type = string
}