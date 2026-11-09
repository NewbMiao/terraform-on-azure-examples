package tflint

import rego.v1

harbor_bad(type, schema, options) := terraform.mock_resources(type, schema, options, {"main.tf": `
resource "terraform_data" "harbor_rg_name" {
  input = "rg-harbor-eg-01"
}
`})

test_deny_invalid_eg_resource_group_name_harbor_failed if {
	issues := deny_invalid_eg_resource_group_name with terraform.resources as harbor_bad
	count(issues) == 1
}

harbor_ok(type, schema, options) := terraform.mock_resources(type, schema, options, {"main.tf": `
resource "terraform_data" "harbor_rg_name" {
  input = "RG-EG-HARBOR-SEA-01"
}
`})

test_deny_invalid_eg_resource_group_name_harbor_passed if {
	issues := deny_invalid_eg_resource_group_name with terraform.resources as harbor_ok
	count(issues) == 0
}
