# Root variables are uniformly type = any: type boundaries belong to the child modules in the real repo; the example only shows how config flows to resources.
variable "subscriptions" {
  type = any
}

variable "org_lgw" {
  type = any
}

# Gate 1: DeployIfNotExists — listed resource types get wired to the org LGW automatically
variable "diagnostic_gates" {
  type = any
}

# deny_gates — gate 2: no new LGWs in the subscription
variable "deny_gates" {
  type = any
}
