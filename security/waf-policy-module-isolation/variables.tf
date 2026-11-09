# ---------------------------------------------------------------------------
# Root-module variables stay loose: each isolated *.auto.tfvars maps to one variable.
# type = any because the long, deeply nested object({…}) is defined once in the
# child module.
# If every variable spelled out the full type, adding one nested field later
# would mean edits in many places
# (see _anti_pattern/root_variables_heavy.tf.example).
# ---------------------------------------------------------------------------

variable "policy_sea_dev" {
  description = "SEA region dev config (from sea_dev.auto.tfvars)."
  type        = any
}

variable "policy_sea_prod" {
  description = "SEA region prod config (from sea_prod.auto.tfvars)."
  type        = any
}

variable "policy_relay_dev" {
  description = "relay app dev config (from relay_dev.auto.tfvars)."
  type        = any
}

variable "policy_relay_prod" {
  description = "relay app prod config (from relay_prod.auto.tfvars)."
  type        = any
}
