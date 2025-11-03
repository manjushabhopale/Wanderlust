variable "aws_region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "ap-south-1" # Change to your desired region
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "wanderlust"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31" # Specify your desired K8s version
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t2.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}