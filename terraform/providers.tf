# ====================================================================================
# AKAMAI MAPPING REFERENCE: Pipeline Portability & Infrastructure Agnostic Layer
# ====================================================================================
# This block sets up the baseline infrastructure provider environment.
# While utilizing open-source provider wrappers to bypass enterprise credential locks, 
# this architecture is explicitly decoupled to allow a drop-in replacement using the 
# native Akamai Terraform Provider ("akamai/akamai") within a production pipeline.
# ====================================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# The access token is securely injected dynamically via corporate CI/CD environment variables
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

