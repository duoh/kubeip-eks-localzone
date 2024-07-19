output "elastic_ips" {
  value = aws_eip.kubeip[*].public_ip
}