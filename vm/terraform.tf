terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.82.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}