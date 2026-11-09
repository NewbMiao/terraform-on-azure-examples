# Plays a team Resource Group's name (in production: azurerm_resource_group.name; the example doesn't touch Azure)
resource "terraform_data" "harbor_rg_name" {
  input = "rg-harbor-eg-01"
}
