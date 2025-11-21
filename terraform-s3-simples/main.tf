# 1. Configuração do Terraform e Provider AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Use a região configurada no aws configure
  region = "us-east-1" 
}

# 2. Definição do Recurso (O S3 Bucket)
resource "aws_s3_bucket" "meu_primeiro_bucket" {
  # nome único para o bucket"
  bucket = "terraform-s3-simples-bucket-6666" 

  tags = {
    Name        = "Primeiro Lab Terraform"
    Ambiente    = "Dev"
  }
}
