locals {
  cells = {
    cell_a = {
      name = "cell-a"
    }
    cell_b = {
      name = "cell-b"
    }
  }
}

# Placeholder VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Placeholder EKS cluster (replace with module in real usage)
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"

  vpc_config {
    subnet_ids = []
  }
}
