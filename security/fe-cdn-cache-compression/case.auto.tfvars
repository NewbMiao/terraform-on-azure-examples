edge = {
  profile     = "edge-dev"
  endpoint    = "relay-dev"
  origin_key  = "relay-dev"
  origin_host = "relay-dev.internal.example"

  # Compression is owned by Front Door; the origin layer is off by default
  origin_compress = false

  # Exception list: these paths are still cached, Front Door just doesn't compress them
  no_compress_patterns = ["/legacy/download/*"]
}

apps = {
  relay = {
    host_name = "relay.example.com"
    page = {
      pattern = "/*"
    }
    cached = {
      next_static = {
        pattern                       = "/_next/static/*"
        query_string_caching_behavior = "IgnoreQueryString"
        ttl                           = "30d"
      }
      image_optimizer = {
        pattern                       = "/_next/image"
        query_string_caching_behavior = "IncludeQueryString"
        ttl                           = "7d"
      }
      # Paths on the exception list: still cached, just not compressed by Front Door
      legacy_download = {
        pattern                       = "/legacy/download/*"
        query_string_caching_behavior = "IgnoreQueryString"
        ttl                           = "1d"
      }
    }
  }

  pulse = {
    host_name = "pulse.example.com"
    page = {
      pattern = "/*"
    }
    cached = {
      vite_assets = {
        pattern                       = "/assets/*"
        query_string_caching_behavior = "IgnoreQueryString"
        ttl                           = "30d"
      }
    }
  }

  harbor = {
    host_name = "harbor.example.com"
    page = {
      pattern = "/*"
    }
    # Pure server-side rendering, no static assets; leave cached out and the expansion is naturally empty
  }
}
