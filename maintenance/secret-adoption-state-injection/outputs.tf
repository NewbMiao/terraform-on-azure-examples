output "credential_metadata" {
  description = "After injection, the outside world sees only this: key_id, name, end date."
  value       = local.credential_metadata
}

output "admin_password_version" {
  description = "The server's password gate: only when it changes does the provider push the random_password value."
  value       = terraform_data.server.input.administrator_password_wo_version
}

output "key_vault_secret_expiry" {
  description = "The shareable half of the copy list: which source each follows and when it expires."
  value = { for k, s in terraform_data.key_vault_secret : k => {
    source          = s.input.source
    expiration_date = s.input.expiration_date
  } }
}

output "key_vault_secrets" {
  description = "Full shape of each copy: value keeps only a hash, but the hash derives from plaintext, so the whole thing is marked sensitive."
  value       = { for k, s in terraform_data.key_vault_secret : k => s.input }
  sensitive   = true
}
