locals {
  policy_attachments = flatten([
    for group in var.rbac : [
      for policy in group.policies : {
        group_name = group.name
        policy_arn = policy
      }
    ]
  ])
}

resource "aws_iam_group" "groups" {
    for_each = { for rbac in var.rbac : rbac.name => rbac }
    name     = each.key
}

resource "aws_iam_group_policy_attachment" "policies" {
  for_each   = { for item in local.policy_attachments : "${item.group_name}-${item.policy_arn}" => item }

  group      = aws_iam_group.groups[each.value.group_name].name
  policy_arn = each.value.policy_arn
}