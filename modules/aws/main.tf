locals {
  aws_user = { for user in var.users : user["username"] => user if contains(keys(user), "aws") }
}

resource "aws_iam_user" "user" {
  for_each = local.aws_user
  name                 = each.value["username"]
  path                 = lookup(each.value, "path", "/")
  tags                 = lookup(each.value, "tags", {})
  permissions_boundary = lookup(each.value["aws"], "permissions_boundary", null)
}

resource "aws_iam_user_login_profile" "user_login_profile" {
  for_each                = local.aws_user
  user                    = aws_iam_user.user[each.value["username"]].name
  password_reset_required = true

}

resource "aws_iam_user_group_membership" "membership" {
  for_each = local.aws_user

  groups   = each.value["aws"].group
  user     = each.value.username

  depends_on = [ 
    aws_iam_user.user
  ]
}