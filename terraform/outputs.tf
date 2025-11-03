output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.default_vpc_eks.name
}

