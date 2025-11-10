module "vpc" {
  source = "../../modules/vpc"

  name                = "uat"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  azs = ["us-east-1a", "us-east-1b"]

  tags = {
    Environment = "uat"
    Project     = "eks-setup"
  }
}


module "eks" {
  source = "../../modules/eks"

  name             = "uat-eks-cluster"
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnet_ids
  private_subnets  = module.vpc.private_subnet_ids
  cluster_name ="uat-eks-cluster"
  node_instance_types = ["t3.medium"]
  node_min     = 1
  node_desired = 2
  node_max     = 3

  tags = {
    Environment = "uat"
    Project     = "eks-setup"
  }
}
