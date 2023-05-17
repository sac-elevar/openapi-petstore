provider "aws" {
  region = var.region
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "sac-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length = 8
  special = false
}