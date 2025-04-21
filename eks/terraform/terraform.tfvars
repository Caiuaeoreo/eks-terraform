region            = "us-east-1"
cluster_name      = "eks-cluster"
environment       = "dev"
vpc_cidr          = "10.0.0.0/16"
kubernetes_version = "1.32"
min_nodes         = 1
max_nodes         = 2
desired_nodes     = 1

tags = {
  Environment = "dev"
  Terraform   = "true"
  Project     = "eks-deployment"
  Owner       = "terraform"
}
