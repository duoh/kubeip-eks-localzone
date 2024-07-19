region                     = "ap-southeast-1"
vpc_id                     = "vpc-0aef438562ae4d62c"
private_subnets            = [
                                "subnet-00cc5cc97f92fad69",
  "subnet-0536c4e2a1ddfdcdd",
  "subnet-09a845d2f12870a54",
                             ]
public_subnets_local_zone  = "subnet-0346f3597ba70f67e"
cluster_name               = "kubeip-lz-cluster"
kubeip_role_name           = "kubeip-agent-role"
kubeip_sa_name             = "kubeip-agent-sa"