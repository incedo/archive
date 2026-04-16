provider "aws" {
  region = var.aws_region
}

data "aws_ssoadmin_instances" "this" {}

