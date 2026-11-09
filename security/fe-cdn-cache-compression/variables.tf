variable "edge" {
  type = object({
    profile         = string
    endpoint        = string
    origin_key      = string
    origin_host     = string
    origin_compress = bool
    # Path-level exceptions: still cached, just not compressed by Front Door
    no_compress_patterns = list(string)
  })
}

# One entry per app. The page route is mandatory; static assets may or may not exist per app.
variable "apps" {
  type = map(object({
    host_name = string
    page = object({
      pattern = string
    })
    cached = optional(map(object({
      pattern                       = string
      query_string_caching_behavior = string
      ttl                           = string
    })), {})
  }))
}
