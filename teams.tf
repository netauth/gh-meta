#######################
# Organization Owners #
#######################

resource "github_membership" "org-owner_the-maldridge" {
  username = "the-maldridge"
  role     = "admin"
}

######################
# GitHub Memberships #
######################

locals {
  github_teams = {
    core-dev = {
      description = "Developers of the entire ecosystem"
      maintainers = [
        "the-maldridge",
      ]
    }
  }
}

resource "github_team" "teams" {
  for_each = local.github_teams

  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team_membership" "team_membership" {
  for_each = { for i in flatten([for team_name, team in local.github_teams : [
    [for username in lookup(team, "maintainers", []) : { team_name = team_name, role = "maintainer", username = username }],
    [for username in lookup(team, "members", []) : { team_name = team_name, role = "member", username = username }],
  ]]) : "${i.team_name}_${i.username}" => i }

  team_id  = github_team.teams[each.value.team_name].id
  role     = each.value.role
  username = each.value.username
}
