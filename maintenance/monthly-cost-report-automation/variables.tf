variable "subscriptions" {
  type = map(object({
    subscription_id = string
  }))
}

variable "automation" {
  type = any
}
