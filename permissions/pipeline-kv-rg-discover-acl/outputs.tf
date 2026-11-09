output "binding_keys" {
  value = sort(keys(terraform_data.access_binding))
}

output "skipped_rbac_vaults" {
  value = sort([
    for k, row in local.vaults_flat :
    "${row.resource_group_name}/${row.vault_name}"
    if local.vault_data[k].rbac_mode
  ])
}

output "bindings_by_principal_kind" {
  value = {
    sp = sort([
      for k, row in terraform_data.access_binding :
      k if row.input.principal_kind == "sp"
    ])
    sgrp = sort([
      for k, row in terraform_data.access_binding :
      k if row.input.principal_kind == "sgrp"
    ])
  }
}

output "sample_dev_sgrp_permissions" {
  description = "SGRP secret permission tier on the dev subscription (should include Set/Delete in this example)."
  value = try([
    for _, row in terraform_data.access_binding :
    row.input.secret_permissions
    if row.input.principal_kind == "sgrp" && row.input.subscription_key == "dev"
  ][0], [])
}

output "sample_prod_sgrp_permissions" {
  description = "SGRP on the prod subscription gets List only."
  value = try([
    for _, row in terraform_data.access_binding :
    row.input.secret_permissions
    if row.input.principal_kind == "sgrp" && row.input.subscription_key == "prod"
  ][0], [])
}

output "sample_sc_permissions" {
  description = "Team SCs get fixed Get/List on ACL vaults."
  value = try([
    for _, row in terraform_data.access_binding :
    row.input.secret_permissions
    if row.input.principal_kind == "sp"
  ][0], [])
}
