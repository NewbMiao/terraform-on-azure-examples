config {
  call_module_type = "local"
  force            = false
}

# Regular: Terraform language and module hygiene (required_version, required_providers, unused declarations, …)
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# The example stack deliberately omits terraform { required_version }; the rule is off so it doesn't drown out the unused + OPA demo.
rule "terraform_required_version" {
  enabled = false
}

# The azurerm ruleset is off in this example (no azurerm resources in the stack, no Azure login needed); real repos can enable it.

# Org conventions: Rego policies (naming sheets, etc.), needs TFLINT_OPA_POLICY_DIR
plugin "opa" {
  enabled = true
  version = "0.11.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}
