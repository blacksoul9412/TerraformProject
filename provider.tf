terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVSVXSQTEEGJGNM7P"
  secret_key = "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"
}

