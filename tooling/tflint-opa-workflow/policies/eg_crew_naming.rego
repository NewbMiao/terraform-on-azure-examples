package tflint

import rego.v1

# Fictional EG naming: the example stack plays the RG name with terraform_data.input (string); in production the Rego scans azurerm_resource_group.name.
deny_invalid_eg_resource_group_name contains issue if {
	rds := terraform.resources("terraform_data", {"input": "string"}, {})
	rd := rds[_]
	name := rd.config.input
	is_string(name.value)
	not startswith(name.value, "RG-EG-")

	issue := tflint.issue(
		sprintf("Resource group name must start with \"RG-EG-\" (got %v)", [name.value]),
		name.range,
	)
}
