provider "aws" {
  region = "us-west-2"
}

# Create EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27.16"  #
  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  node_groups = {
    eks_x86_nodes = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
    eks_arm_nodes = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "m6g.medium"  # Graviton instance type
    }
  }
}

# Configure IAM Roles and Policies for Karpenter
resource "aws_iam_role" "karpenter" {
  name               = "KarpenterControllerRole"
  assume_role_policy = jsonencode({ "Version": "2012-10-17", "Statement": [{ "Action": "sts:AssumeRole", "Effect": "Allow", "Principal": { "Service": "eks.amazonaws.com" } }] })
}

resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
