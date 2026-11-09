output "workbook_display_name" {
  value = var.workbook.display_name
}

output "workbook_item_count" {
  value = length(jsondecode(local.workbook_data_json).items)
}

output "workbook_kql_titles" {
  value = [
    for item in jsondecode(local.workbook_data_json).items :
    try(item.content.title, null)
    if item.type == 3
  ]
}
