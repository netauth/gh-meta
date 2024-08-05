locals {
  github_repos = {

    ###################
    # Core Components #
    ###################

    netauth = {
      description  = "The NetAuth service itself."
      homepage_url = "https://netauth.org"
      teams        = ["core-dev"]
      topics = [
        "authentication-service",
        "golang",
        "secure-access",
      ]
    }

    protocol = {
      description = "The Protobuf files for the NetAuth GRPC protocol"
      teams       = ["core-dev"]
      topics = [
        "protobuf",
        "protocol",
        "rpc",
      ]
    }

    ############
    # Websites #
    ############

    docs = {
      description = "Documentaiton for NetAuth"
      teams       = ["core-dev"]
      topics = [
        "documentation",
        "mdbook",
      ]
    }

    "netauth.org" = {
      description  = "hugo source files for netauth.org"
      homepage_url = "https://netauth.org"
      teams        = ["core-dev"]
      topics = [
        "devblog",
        "docs",
        "hugo-site",
      ]
    }

    ################################
    # Interoperability & Ecosystem #
    ################################

    authserver = {
      description = "A web microservice suitable for using request delegation authentication."
      teams       = ["core-dev"]
      topics = [
        "authentication-backend",
        "secure-login",
      ]
    }

    ldap = {
      description = "An LDAP proxy for connecting LDAP aware applications to NetAuth"
      teams       = ["core-dev"]
      topics = [
        "ldap",
        "proxy",
      ]
    }

    localizer = {
      description = "A tool to make your NetAuth accounts local"
      teams       = ["core-dev"]
      topics = [
        "identity",
        "shadow-database",
      ]
    }

    netkeys = {
      description = "An AuthorizedKeysCommand implementation for NetAuth"
      teams       = ["core-dev"]
      topics = [
        "ssh",
        "authentication-backend",
        "secure-login",
      ]
    }

    nsscache = {
      description = "Tool to create nsscache maps from NetAuth"
      teams       = ["core-dev"]
      topics = [
        "identity",
        "authorization",
        "nss",
      ]
    }

    pam-helper = {
      description = "A helper executable to use with pam_exec"
      teams       = ["core-dev"]
      topics = [
        "authentication",
        "pam",
      ]
    }

    pam_netauth = {
      description = "PAM plugin which implements the NetAuth protocol"
      teams       = ["core-dev"]
      topics = [
        "authentication",
        "pam-module",
        "secure-login",
        "pam-authentication",
      ]
    }

    webui = {
      description = "A web interface for NetAuth"
      teams       = ["core-dev"]
      topics = [
        "web-frontend",
        "gui",
      ]
    }

    netauth-python = {
      description  = "NetAuth client library for Python"
      homepage_url = "https://python.netauth.org"
      teams        = ["core-dev", "python-dev"]
      topics = [
        "secure-access",
        "authentication-service",
        "python",
      ]
    }

    ###########
    # Plugins #
    ###########

    plugin-okta = {
      description = "A NetAuth plugin which mirrors changes to Okta"
      teams       = ["core-dev"]
      topics = [
        "okta-api",
        "secure-access",
        "security-tools",
      ]
    }

    gh-meta = {
      # How Meta!
      description = "Terraform source for managing github"
      teams       = ["core-dev"]
      topics      = ["terraform"]
    }
  }
}

resource "github_repository" "repositories" {
  for_each = local.github_repos

  name               = each.key
  description        = each.value.description
  has_issues         = true
  has_downloads      = true
  has_projects       = false
  has_wiki           = false
  homepage_url       = lookup(each.value, "homepage_url", null)
  allow_merge_commit = lookup(each.value, "allow_merge_commit", false)
  allow_squash_merge = lookup(each.value, "allow_squash_merge", false)
  topics             = flatten([lookup(each.value, "topics", []), ["netauth"]])

  vulnerability_alerts = true
}

resource "github_team_repository" "team_repositories" {
  for_each = { for i in flatten([for repo_name, repo in local.github_repos :
    [for team_name in repo.teams : { repo_name = repo_name, team_name = team_name }]
  ]) : "${i.repo_name}_${i.team_name}" => i }

  team_id    = github_team.teams[each.value.team_name].id
  repository = github_repository.repositories[each.value.repo_name].name
  permission = "push"
}
