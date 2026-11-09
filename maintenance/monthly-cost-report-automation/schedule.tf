# Plays azurerm_automation_schedule
resource "terraform_data" "monthly_cost_report_schedule" {
  count = local.enabled ? 1 : 0

  input = {
    name                        = "sched-app-monthly-cost-report"
    frequency                   = "Month"
    interval                    = 1
    timezone                    = local.report.schedule.timezone
    month_days                  = [local.report.schedule.day_of_month]
    start_time                  = local.schedule_start_time
    lifecycle_ignore_start_time = true
  }
}

# Plays azurerm_automation_job_schedule
resource "terraform_data" "monthly_cost_report_job_schedule" {
  count = local.enabled ? 1 : 0

  input = {
    schedule_name = terraform_data.monthly_cost_report_schedule[0].input.name
    runbook_name  = terraform_data.monthly_cost_report_runbook[0].input.name
  }
}
