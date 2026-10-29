# ====================================================================================
# AKAMAI MAPPING REFERENCE: Environment Abstraction (Contract & Group Scoping)
# ====================================================================================
# In an Akamai-native deployment, these input layers mirror the structural layout of 
# Akamai parameters—mapping public hostnames directly to localized Contract IDs (ctr_X) 
# and structural Access Group IDs (grp_X) inside Akamai Control Center.
# ====================================================================================

variable "cloudflare_api_token" {
  type        = string
  description = "The secure API authorization token with fine-grained WAF and Zone editing permissions."
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The target zone identifier (Maps directly to an Akamai Digital Property ID configuration)."
}

variable "domain_name" {
  type        = string
  default     = "://example.com"
  description = "The user-facing digital asset domain name mapped onto the edge server delivery layer."
}

variable "origin_hostname" {
  type        = string
  default     = "://amazonaws.com"
  description = "The target cloud infrastructure backend (Corresponds to Akamai's verificationMode: CUSTOMER origin)."
}

