resource "terraform_data" "origin" {
  # Azure resource: azurerm_cdn_frontdoor_origin
  input = {
    origin_group = var.edge.origin_key
    host_name    = var.edge.origin_host
    profile      = var.edge.profile
    endpoint     = var.edge.endpoint
    # Whether this layer compresses decides if Front Door still can
    compress = var.edge.origin_compress
  }
}

resource "terraform_data" "page_route" {
  # Azure resource: azurerm_cdn_frontdoor_route
  for_each = local.page_routes

  input = {
    name              = each.value.name
    host_name         = each.value.host_name
    patterns_to_match = each.value.patterns_to_match
    origin            = terraform_data.origin.output.host_name
    # No cache block means no caching
    cache = null
  }
}

resource "terraform_data" "static_route" {
  # Azure resource: azurerm_cdn_frontdoor_route
  for_each = local.static_routes

  input = {
    name              = each.value.name
    host_name         = each.value.host_name
    patterns_to_match = each.value.patterns_to_match

    cache = {
      query_string_caching_behavior = each.value.query_string_caching_behavior
      content_types_to_compress     = each.value.content_types_to_compress
      # This one flag decides whether the response gets compressed once or twice
      compression_enabled = each.value.compression_enabled
      # Only a hash in the name justifies a long TTL
      content_hash_in_name = each.value.content_hash_in_name
      ttl                  = each.value.ttl
    }
  }

  depends_on = [terraform_data.origin]
}
