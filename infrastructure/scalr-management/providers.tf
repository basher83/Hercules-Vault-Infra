provider "scalr" {
  hostname = var.scalr_hostname
  token    = var.scalr_token
}

provider "infisical" {
  # Automatically uses environment variables:
  # INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
  # INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
  auth = {
    universal = {
      # client_id and client_secret are read from environment variables:
      # INFISICAL_UNIVERSAL_AUTH_CLIENT_ID and INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
    }
  }
}
