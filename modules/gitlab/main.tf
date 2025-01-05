locals {
  gitlab_users = { for user in var.users : user["username"] => user if contains(keys(user), "gitlab") }
}

data "gitlab_groups" "this" {  
  depends_on = [ gitlab_group.groups ]
}

locals {
  formatted_groups = { for g in data.gitlab_groups.this.groups : g.name => g.group_id }
}

locals {
  # Flatten user-group mapping with group name and access level
  user_group_mapping = flatten([
    for user_key, user_data in local.gitlab_users : [
      for group_with_access in user_data.gitlab.group : {
        username     = user_data.username
        user_id      = gitlab_user.user[user_data.username].id
        group_name   = can(split("::", group_with_access)[0]) ? split("::", group_with_access)[0] : group_with_access
        access_level = length(split("::", group_with_access)) > 1 ? split("::", group_with_access)[1] : "developer"
        group_id     = local.formatted_groups[can(split("::", group_with_access)[0]) ? split("::", group_with_access)[0] : group_with_access]
      }
    ]
  ])
}

resource "gitlab_user" "user" {
  for_each = local.gitlab_users
  email    = each.value.user_info.email
  username = each.value.username
  name     = each.value.user_info.name
  reset_password = true
  state    = lookup(each.value["gitlab"], "state", "active")
}

resource "gitlab_group_membership" "group_membership" {
  for_each = { for idx, mapping in local.user_group_mapping : "${mapping.username}-${mapping.group_name}" => mapping }

  user_id      = each.value.user_id
  group_id     = each.value.group_id
  access_level = each.value.access_level

  depends_on   = [gitlab_user.user]
}