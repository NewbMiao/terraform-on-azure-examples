locals {
  team_keys = sort(keys(var.teams))

  member_rows = merge([
    for team_key, team in var.teams : {
      for local_part in team.members :
      "${team_key}:${local_part}" => {
        team_key   = team_key
        group      = team.security_group.display_name
        member_upn = strcontains(local_part, "@") ? local_part : "${local_part}@${var.member_email_domain}"
      }
    }
  ]...)
}

resource "terraform_data" "security_group_members" {
  for_each = local.member_rows

  input = {
    team_key = each.value.team_key
    group    = each.value.group
    member   = each.value.member_upn
  }
}
