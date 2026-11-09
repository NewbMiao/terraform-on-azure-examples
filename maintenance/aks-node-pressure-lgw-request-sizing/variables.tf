variable "workbook" {
  description = "AKS sizing workbook — LGW id, cluster/namespace pills, KQL from rank.kql."
  type = object({
    display_name      = string
    lgw_workspace_id  = string
    resource_group    = string
    location          = string
    cluster_options   = list(object({ value = string, label = string }))
    cluster_default   = string
    namespace_options = list(object({ value = string, label = string }))
    namespace_default = list(string)
  })
}
