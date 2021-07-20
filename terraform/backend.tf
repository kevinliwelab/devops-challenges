# Backend configuration is loaded early so we can't use variables
resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-lock"
  read_capacity = 5
  write_capacity = 5
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = ">= 2.65"
  }
  
  backend "s3" {
    region  = var.aws_region
    bucket  = "devops-challenge-terraform-state"
    key     = "terraform.tfstate"
    encrypt = true
    dynamodb_table = "terraform-lock"
  }
}
