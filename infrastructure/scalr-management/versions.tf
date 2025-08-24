terraform {
  required_version = ">= 1.10.0"

  required_providers {
    scalr = {
      source  = "Scalr/scalr"
      version = "~> 3.6"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.15.28"
    }
  }
}


