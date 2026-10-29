# ====================================================================================
# AKAMAI MAPPING REFERENCE: Web Application Firewall (WAF) & App & API Protector
# ====================================================================================
# This file represents the custom rule override block inside Akamai's AppSec Engine.
# In a live Akamai ecosystem, these manual regex patterns are abstracted away using 
# the Adaptive Security Engine (ASE_AUTO) to automatically toggle Attack Group behaviors.
# ====================================================================================

resource "cloudflare_ruleset" "edge_security_perimeter" {
  zone_id     = var.cloudflare_zone_id
  name        = "Enterprise WAP Edge Protection Policy"
  description = "Managed via Terraform - Mirrors Akamai AppSec Attack Group Actions"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # ----------------------------------------------------------------------------------
  # SECURITY MAPPING: Akamai SQLi Attack Group -> Action: Deny
  # ----------------------------------------------------------------------------------
  # Intercepts inbound database exploits at the internet edge. This mimics shifting 
  # the native Akamai Web Application Protector SQLi control matrix into active blocking.
  rules {
    action      = "block"
    description = "Akamai WAF Attack Group: SQL Injection mitigation block"
    enabled     = true
    expression  = "(lower(http.request.uri.path) contains \"select \" and lower(http.request.uri.path) contains \"from \") or (lower(http.request.uri.query) contains \"select \" and lower(http.request.uri.query) contains \"from \") or (http.request.uri.path matches \"(?i)(union.*select|concat.*\\\\()\")"

    action_parameters {
      response {
        status_code  = 403
        content_type = "text/plain"
        content      = "Access Denied: Malicious Request Intercepted by Enterprise WAP Edge Shield."
      }
    }
  }

  # ----------------------------------------------------------------------------------
  # SECURITY MAPPING: Akamai XSS Attack Group -> Action: Deny
  # ----------------------------------------------------------------------------------
  # Blocks malicious client-side script execution. Corresponds directly to Akamai's 
  # automated Web Application Protector Cross-Site Scripting signature defense.
  rules {
    action      = "block"
    description = "Akamai WAF Attack Group: Cross-Site Scripting mitigation block"
    enabled     = true
    expression  = "(http.request.uri.path contains \"<script>\") or (http.request.uri.query contains \"<script>\") or (http.request.uri.path matches \"(?i)(javascript:|onerror=|onload=)\")"

    action_parameters {
      response {
        status_code  = 403
        content_type = "text/plain"
        content      = "Access Denied: Malicious Script Execution Intercepted by Enterprise WAP Edge Shield."
      }
    }
  }

  # ----------------------------------------------------------------------------------
  # SECURITY MAPPING: Akamai Bot Manager -> Client-Side Cryptographic Challenge
  # ----------------------------------------------------------------------------------
  # Intercepts directory enumeration and malicious scraping attempts. This mimics 
  # an Akamai Bot Manager configuration issuing a client challenge to rogue automated scanners.
  rules {
    action      = "challenge" 
    description = "Akamai Bot Manager Mitigation: Issue cryptographic challenge to non-human automated scanners"
    enabled     = true
    expression  = "(http.request.uri.path starts_with \"/wp-admin\") or (http.request.uri.path ends_with \".env\") or (http.request.uri.path ends_with \".git/config\")"
  }
}

