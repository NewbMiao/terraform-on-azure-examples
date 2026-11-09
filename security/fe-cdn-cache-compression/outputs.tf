output "compression_owner" {
  description = "Which layer compresses: origin or front_door"
  value       = var.edge.origin_compress ? "origin" : "front_door"
}

# Cache and compression shape per route: the page route has cache = null, the static ones carry cache.
output "routes" {
  value = {
    for k, v in merge(
      { for key, route in local.page_routes : key => { patterns = route.patterns_to_match, cache = null } },
      { for key, route in local.static_routes : key => {
        patterns = route.patterns_to_match
        cache = {
          compression_enabled           = route.compression_enabled
          query_string_caching_behavior = route.query_string_caching_behavior
          ttl                           = route.ttl
          content_hash_in_name          = route.content_hash_in_name
        }
      } }
    ) : k => v
  }
}

# Paths on the exception list: still cached, just with compression_enabled = false.
output "compression_exceptions" {
  value = {
    for key, route in local.static_routes : key => route.patterns_to_match[0]
    if !route.compression_enabled
  }
}

output "overlapping_patterns" {
  description = "Apps whose page and static patterns collide; should be empty"
  value       = local.overlapping_patterns
}
