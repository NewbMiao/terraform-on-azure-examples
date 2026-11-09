app_apis = {
  "relay-partner-api" = {
    path           = "relay/partner"
    backend_id     = "relay-partner-api"
    openapi_file   = "relay-partner-openapi.json"
    portal_managed = true
  }
  "pulse-internal-api" = {
    path           = "pulse/internal"
    backend_id     = "pulse-internal-api"
    openapi_file   = "pulse-internal-openapi.json"
    portal_managed = false
  }
}

app_products = {
  "relay-partner" = {
    api_names = ["relay-partner-api"]
  }
  "pulse-suite" = {
    # The pulse product only links internal; if relay unlinks an API in the Portal, remove it from api_names here instead of ignoring product_api
    api_names = ["pulse-internal-api"]
  }
}

apim_api_access = {
  relay = {
    api_names          = ["relay-partner-api"]
    backend_names      = ["relay-partner-api"]
    product_names      = ["relay-partner"]
    subscription_names = ["relay-partner-key"]
    named_value_names  = ["relay-backend-key"]
    users              = ["owen.relay"]
  }
  pulse = {
    api_names     = ["pulse-internal-api"]
    backend_names = ["pulse-internal-api"]
    product_names = ["pulse-suite"]
    users         = ["bob.pulse"]
  }
}
