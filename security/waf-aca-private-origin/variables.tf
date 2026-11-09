variable "aca" {
  type = object({
    app_name        = string
    origin_hostname = string
  })
}

variable "waf" {
  type = object({
    public_hostname = string
    profile         = string
  })
}
