locals {
  # Node subnet NSG: the allowlist covers outbound only; no deny on VirtualNetwork
  # (control-plane↔node, node-to-node VXLAN, kubelet, and LB probes all ride VNet-internal
  # addresses — allowlisting them one by one is not realistic)
  nsg_rules = merge(
    {
      "out/pe_db/${var.nsg_edges.db_port}" = {
        direction         = "Outbound"
        access            = "Allow"
        priority          = 200
        source_cidr       = var.cluster.node_subnet_cidr
        destination_cidr  = var.nsg_edges.pe_db_cidr
        destination_ports = tostring(var.nsg_edges.db_port)
        note              = "Pods reach the DB PE via node egress"
      }
      "in/AzureLoadBalancer" = {
        direction         = "Inbound"
        access            = "Allow"
        priority          = 100
        source_address    = "AzureLoadBalancer"
        destination_cidr  = var.cluster.node_subnet_cidr
        destination_ports = "*"
        note              = "Internal ILB / PLS health probes"
      }
    },
    var.nsg_edges.nat_egress ? {
      "out/nat/443" = {
        direction         = "Outbound"
        access            = "Allow"
        priority          = 210
        source_cidr       = var.cluster.node_subnet_cidr
        destination_cidr  = "Internet"
        destination_ports = "443"
        note              = "Egress via NAT (images, telemetry)"
      }
    } : {}
  )
}

resource "terraform_data" "nsg_rule" {
  # Azure resource: azurerm_network_security_rule
  for_each = local.nsg_rules

  input = merge(each.value, {
    subnet = var.cluster.node_subnet_name
    rule   = each.key
  })
}
