terraform {
  required_version = ">= 1.8.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.71"
    }
  }
}
