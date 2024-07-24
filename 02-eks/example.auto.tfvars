region                     = "ap-southeast-1"
vpc_id                     = "vpc-0b0a5c3aa391f86f4"
private_subnets            = [
  "subnet-049be47d046a9bdd5",
  "subnet-0709ff551579e328c",
  "subnet-0df735d7861108477",
                             ]
public_subnets_local_zone  = "subnet-06e1d81143fc8e040"
cluster_name               = "kubeip-lz-cluster"
kubeip_role_name           = "kubeip-agent-role"
kubeip_sa_name             = "kubeip-agent-sa"
