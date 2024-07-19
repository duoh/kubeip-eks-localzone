output "vpc_id" {
  value       = try(module.vpc.vpc_id, "")
}

output "private_subnets" {
  value       = module.vpc.private_subnets
}

output "public_subnets_local_zone" {
  value = aws_subnet.public-subnet-lz.id
}