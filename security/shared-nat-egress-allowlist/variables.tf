variable "network_subnet_ids" {
  description = "Platform VNet subnet catalog: keys are fictional vnet_key/subnet_key pairs (e.g. eg_vnet_apac_prd/aca_crest_prd), values are example subnet ARM IDs."
  type        = map(string)
}

variable "shared_nat_gateways" {
  description = "Shape of the platform NET stack's shared_nat_gateways (subscription_key is dev or prod)."
  type = map(object({
    subscription_key    = string
    vnet_key            = string
    resource_group_name = string
    location            = string
    name                = string
    public_ips = map(object({
      name = string
    }))
    subnet_keys       = list(string)
    include_ado_agent = optional(bool, false) # true: also attach the vnet_key/ado_agent subnet (ADO self-hosted agent, not AKS)
    tags              = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for k, gw in var.shared_nat_gateways :
      contains(["dev", "prod"], gw.subscription_key)
    ])
    error_message = "subscription_key only uses dev or prod in this example (fictional catalog keys)."
  }
}

variable "egress_allowlist" {
  description = "Third-party egress allowlist registration: points at a public_ips key on a NAT."
  type = map(object({
    consumer_label  = string
    nat_gateway_key = string
    public_ip_key   = string
  }))
  default = {}
}

variable "inbound_allowlist" {
  description = "Inbound registration (edge); kept separate from NAT egress so nobody fills in Front Door / AFD by mistake."
  type = map(object({
    consumer_label = string
    edge_kind      = string
    address        = string
  }))
  default = {}
}
