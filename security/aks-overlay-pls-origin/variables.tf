variable "cluster" {
  type = object({
    name             = string
    node_subnet_name = string
    node_subnet_cidr = string
    pod_cidr         = string
    node_count       = number
  })
  description = "AKS cluster network shape: nodes live in a shared VNet subnet, Pods ride the overlay range."
}

variable "nsg_edges" {
  type = object({
    pe_db_cidr = string
    db_port    = number
    nat_egress = bool
  })
  description = "Node subnet NSG outbound allowlist: DB PE subnet + NAT; no deny on VirtualNetwork."
}

variable "pls" {
  type = object({
    name         = string
    request_note = string
  })
  description = "The Private Link Service the cloud controller creates from the Service annotations."
}

variable "waf" {
  type = object({
    profile         = string
    public_hostname = string
  })
  description = "The org Front Door: hostname and certificate live at the edge."
}
