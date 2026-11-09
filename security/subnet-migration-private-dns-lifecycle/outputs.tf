output "dns_verify_keys" {
  value = sort(keys(terraform_data.private_dns_a_record_verify))
}

output "stpulseprd_dns_match" {
  description = "Whether the blob account's A record contains the surviving PE IP (after deleting the legacy PE, emptying dns_a_records should make plan fail)."
  value = contains(
    coalesce(var.private_link_dns["stpulseprd_blob"].dns_a_records, []),
    var.private_link_dns["stpulseprd_blob"].pe_private_ip
  )
}

output "storage_pe_verify_enabled" {
  value = {
    for k, row in terraform_data.storage_pe :
    k => row.input.private_dns.verify_a_record
  }
}
