region                     = "ap-southeast-1"
vpc_id                     = "vpc-0fc56b98e932be8da"
private_subnets            = [
  "subnet-0a10595c6291363fe",
  "subnet-0d57126f680353dbb",
  "subnet-098673b4041795af0",
                             ]
public_subnets_local_zone  = "subnet-0ab7b9bc4abf87c29"
cluster_name               = "kubeip-eks-lz-cluster"
kubeip_role_name           = "kubeip-agent-role"
kubeip_sa_name             = "kubeip-agent-sa"
