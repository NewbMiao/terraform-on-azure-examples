# azurerm_linux_virtual_machine_scale_set — the ADO agent runs in the ado_agent subnet
resource "terraform_data" "ado_agent_vmss" {
  input = {
    azure_resource      = "azurerm_linux_virtual_machine_scale_set"
    name                = var.ado_elastic_pool.vmss_name
    resource_group_name = "RG-EG-DEV-ADO-SEA"
    subnet_name         = var.ado_agent.subnet_name
    sku                 = "Standard_E2ads_v5"
    instances           = 0
  }
}

# azuredevops_elastic_pool — a WIF ARM service connection attached to the VMSS
resource "terraform_data" "ado_elastic_pool" {
  input = {
    azure_resource      = "azuredevops_elastic_pool"
    name                = var.ado_elastic_pool.name
    service_endpoint_id = var.ado_elastic_pool.service_endpoint_name
    azure_resource_id   = terraform_data.ado_agent_vmss.input.name
    desired_idle        = var.ado_elastic_pool.desired_idle
    max_capacity        = var.ado_elastic_pool.max_capacity
    note                = "the db_migrate job's pool matches name"
  }
}
