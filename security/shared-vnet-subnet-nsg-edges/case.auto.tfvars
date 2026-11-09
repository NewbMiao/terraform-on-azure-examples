virtual_networks = {
  dev_sea_01 = {
    name             = "VNET-EG-DEV-SEA-01"
    location         = "southeastasia"
    address_space    = ["172.20.0.0/22"]
    subscription_key = "dev"
    subnets = {
      aca_relay_dev = {
        name             = "SNET-EG-DEV-ACA-RELAY"
        address_prefixes = ["172.20.0.0/26"]
        delegation = {
          name         = "Microsoft.App/environments"
          service_name = "Microsoft.App/environments"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      aca_pulse_dev = {
        name             = "SNET-EG-DEV-ACA-PULSE"
        address_prefixes = ["172.20.0.64/27"]
        delegation = {
          name         = "Microsoft.App/environments"
          service_name = "Microsoft.App/environments"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      pe_db_dev = {
        name             = "SNET-EG-DEV-PE-DB"
        address_prefixes = ["172.20.0.128/27"]
      }
      pe_dev = {
        name             = "SNET-EG-DEV-PE"
        address_prefixes = ["172.20.0.160/27"]
      }
    }
  }

  prod_sea_01 = {
    name             = "VNET-EG-PROD-SEA-01"
    location         = "southeastasia"
    address_space    = ["172.21.0.0/22"]
    subscription_key = "prod"
    subnets = {
      aca_relay_prod = {
        name             = "SNET-EG-PROD-ACA-RELAY"
        address_prefixes = ["172.21.0.0/26"]
        delegation = {
          name         = "Microsoft.App/environments"
          service_name = "Microsoft.App/environments"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      aca_pulse_prod = {
        name             = "SNET-EG-PROD-ACA-PULSE"
        address_prefixes = ["172.21.0.64/27"]
        delegation = {
          name         = "Microsoft.App/environments"
          service_name = "Microsoft.App/environments"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      pe_db_prod = {
        name             = "SNET-EG-PROD-PE-DB"
        address_prefixes = ["172.21.0.128/27"]
      }
      pe_prod = {
        name             = "SNET-EG-PROD-PE"
        address_prefixes = ["172.21.0.160/27"]
      }
    }
  }

  prod_ea_01 = {
    name             = "VNET-EG-PROD-EA-01"
    location         = "australiaeast"
    address_space    = ["172.22.0.0/22"]
    subscription_key = "prod"
    subnets = {
      aca_harbor_prod = {
        name             = "SNET-EG-PROD-ACA-HARBOR"
        address_prefixes = ["172.22.0.0/26"]
        delegation = {
          name         = "Microsoft.App/environments"
          service_name = "Microsoft.App/environments"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      pe_db_prod = {
        name             = "SNET-EG-PROD-PE-DB"
        address_prefixes = ["172.22.0.128/27"]
      }
      pe_prod = {
        name             = "SNET-EG-PROD-PE"
        address_prefixes = ["172.22.0.160/27"]
      }
    }
  }
}
