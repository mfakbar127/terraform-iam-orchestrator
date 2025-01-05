resource "gitlab_group" "groups" {
  for_each    = toset(var.rbac.groups)
  name        = each.value
  path        = each.value
}