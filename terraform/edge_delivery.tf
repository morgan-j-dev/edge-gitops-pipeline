# ====================================================================================
# AKAMAI MAPPING REFERENCE: Akamai Property Manager Rules Engine & PAPI Configuration
# ====================================================================================
# This ruleset behaves identically to an Akamai Property Manager "Rule Tree" configuration.
# In a live Akamai architecture, these behaviors are evaluated on a "Last-Match-Wins" 
# hierarchy down the Edge server rule pipeline.
# ====================================================================================

resource "cloudflare_ruleset" "edge_delivery_behavior" {
  zone_id     = var.cloudflare_zone_id
  name        = "Enterprise Edge Delivery Configuration"
  description = "Managed via Terraform - Mirrors Akamai Property Manager Object Rules"
  kind        = "zone"
  phase       = "http_request_dynamic_routing"

  # ----------------------------------------------------------------------------------
  # BEHAVIOR MAPPING: Akamai 'origin' behavior with 'originSni' & 'forwardHostHeader'
  # ----------------------------------------------------------------------------------
  # Maps all incoming public web traffic uniformly to our core cloud hosting origin.
  # This corresponds to the Akamai Origin behavior using verificationMode: PLATFORM_SETTINGS.
  rules {
    action      = "route"
    description = "Akamai Origin Mapping: Route edge traffic to primary cloud origin"
    enabled     = true
    expression  = "true" # Acts as the Akamai Property 'Default Rule' global condition

    action_parameters {
      sni {
        value = var.origin_hostname
      }
      origin {
        host = var.origin_hostname
        port = 443
      }
    }
  }

  # ----------------------------------------------------------------------------------
  # CRITERIA: fileExtension Match | BEHAVIOR: Akamai 'caching' (MAX_AGE)
  # ----------------------------------------------------------------------------------
  # Triggers heavy Edge Offloading to maximize Cache Hit Ratios (CHR) at the Tier-1 edge.
  # In Akamai, this includes enabling 'tieredDistribution' (Origin Shielding) to drop origin load.
  rules {
    action      = "set_config"
    description = "Akamai Caching Behavior: Enforce 30-day edge caching layer for static assets"
    enabled     = true
    # Equivalent to Akamai Property Manager 'fileExtension' criteria match condition
    expression  = "(http.request.uri.path.extension in {\"png\" \"jpg\" \"jpeg\" \"css\" \"js\" \"webp\" \"woff2\"})"

    action_parameters {
      cache = true
      edge_ttl {
        mode    = "respect_origin"
        default = 2592000 # 30 Days (ttl setting in Akamai Property Manager)
      }
    }
  }

  # ----------------------------------------------------------------------------------
  # CRITERIA: path Match | BEHAVIOR: Akamai 'caching' (BYPASS_CACHE)
  # ----------------------------------------------------------------------------------
  # Explicitly enforces uncacheable dynamic exceptions to protect transactional state data.
  # This overrides any global caching rules using Akamai's conditional hierarchical execution.
  rules {
    action      = "set_config"
    description = "Akamai Cache Bypass: Force dynamic paths directly to origin"
    enabled     = true
    # Equivalent to Akamai Property Manager 'path' match criteria mapping
    expression  = "(http.request.uri.path starts_with \"/api/\") or (http.request.uri.path starts_with \"/login\") or (http.request.uri.path starts_with \"/checkout\")"

    action_parameters {
      cache = false # Bypasses edge storage; enforces immediate Akamai SureRoute performance optimization
    }
  }
}

