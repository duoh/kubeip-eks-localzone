output "vpc_id" {
  value       = try(module.vpc.vpc_id, "")
}

output "vpc_id_cidr" {
  value = try(module.vpc.vpc_cidr_block)
}

output "private_subnets" {
  value       = module.vpc.private_subnets
}

output "public_subnets_local_zone" {
  value = aws_subnet.public-subnet-lz.id
}