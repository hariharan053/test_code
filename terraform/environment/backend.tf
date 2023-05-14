provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "c3-dev-dts-edge-terraform-state"
    key = "dts-edge-cluster.tfstate"
    region = "us-east-1"
  }
}
