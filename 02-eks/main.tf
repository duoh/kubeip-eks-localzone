provider "aws" {
  region = var.region
}

resource "aws_security_group" "allow_edge_svc" {
  name        = "allow_edge_svc"
  description = "Allow TCP port 3000 for service exposed via nodeport"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_edge_svc.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30000
  ip_protocol       = "tcp"
  to_port           = 30000
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  cluster_endpoint_public_access = true

  enable_irsa = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2023_x86_64_STANDARD"
  }

  eks_managed_node_groups = {
    region-ng = {
      ami_type      = "AL2023_x86_64_STANDARD"
      instance_type = "t3a.medium"
      min_size      = 1
      subnet_ids    = var.private_subnets

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=,kubeip=use'"

      tags = {
        Name        = "private-node-group"
        environment = "demo"
        public      = "false"
      }

      labels = {
        region  = "true"
      }
    }
  }

  self_managed_node_groups = {
    local-ng = {
      instance_type = "t3.medium"
      min_size      = 1
      subnet_ids    = [var.public_subnets_local_zone]
      launch_template_os = "amazonlinux2eks"
      
      block_device_mappings = {
        device_name = "/dev/xvda"
        ebs = {
          volume_type = "gp2"
          volume_size = "20"
        }
      }

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup=public-lz-ng,kubeip=use'"

      tags = {
        Name        = "public-lz-node-group"
        environment = "demo"
        public      = "true"
        kubeip      = "use"
      }

      vpc_security_group_ids = [
        aws_security_group.allow_edge_svc.id
      ]
    }
  }

  enable_cluster_creator_admin_permissions = true
}

resource "aws_iam_policy" "kubeip-policy" {
  name        = "kubeip-policy"
  description = "KubeIP required permissions"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:DescribeInstances",
          "ec2:DescribeAddresses"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "kubeip_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = var.kubeip_role_name

  role_policy_arns = {
    "kubeip-policy" = aws_iam_policy.kubeip-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.kubeip_sa_name}"]
    }
  }
}