provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      env           = var.environment
    }
  }
}

terraform {
  required_providers {
    aws = {
      version = "~> 3.38.0"
    }
  }
}