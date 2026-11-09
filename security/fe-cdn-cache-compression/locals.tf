locals {
  # Compression has exactly one owner: if the origin compresses, Front Door doesn't.
  front_door_compresses = !var.edge.origin_compress

  # Match order: pages first (broader), static after (the more specific pattern wins).
  # The page route carries no cache, so every request goes back to the origin.
  page_routes = {
    for app_key, app in var.apps : app_key => {
      name              = "${app_key}-page"
      host_name         = app.host_name
      patterns_to_match = [app.page.pattern]
    }
  }

  # Static routes: the only kind that carries cache; the match pattern is more specific than the page one.
  static_routes = merge([
    for app_key, app in var.apps : {
      for route_key, route in app.cached : "${app_key}-${route_key}" => {
        name              = "${app_key}-${route_key}"
        host_name         = app.host_name
        patterns_to_match = [route.pattern]
        # Query-string-driven paths (e.g. image optimization) must be part of the cache key,
        # or two size variants evict each other
        query_string_caching_behavior = route.query_string_caching_behavior
        content_types_to_compress     = ["text/css", "text/javascript", "application/json", "image/svg+xml"]
        ttl                           = route.ttl
        # With a content hash at the end of the filename, the cache key naturally tracks content
        content_hash_in_name = can(regex("(_next/static/|/assets/)", route.pattern))
        # The exception list overrides "compression is owned by Front Door"
        compression_enabled = local.front_door_compresses && !contains(var.edge.no_compress_patterns, route.pattern)
      }
    }
  ]...)

  # When a page pattern and a static pattern collide, the hit order is uncontrollable.
  overlapping_patterns = [
    for app_key, app in var.apps : app_key
    if anytrue([for route in values(app.cached) : route.pattern == app.page.pattern])
  ]
}
