remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "eks-stable-diffusion-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    
    # Add tags to the S3 bucket (optional but recommended)
    s3_bucket_tags = {
      Name        = "Terraform State Store"
      Environment = "dev"
      Terraform   = "true"
    }

    
    # Add DynamoDB table settings for state locking
    dynamodb_table_tags = {
      Name        = "Terraform State Lock Table"
      Environment = "dev"
      Terraform   = "true"
    }
  }
}


inputs = {
  environment = "dev"
  cluster_name = "eks-gpu-dev"
  instance_types = ["m6g.medium", "m6g.large"]
  desired_nodes = 1
  max_nodes = 2
  min_nodes = 1
} 