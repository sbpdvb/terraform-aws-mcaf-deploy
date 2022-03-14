terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null = {
      source = "hashicorp/null"
    }
    github = {
      source = "hashicorp/github"
    }
  }
}
