terraform {
  backend "s3" {
    bucket         = "terraform-state-4a5b7c"
    key            = "iam/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

locals {
  users = yamldecode(file("${path.module}/data/users.yaml"))
}

locals {
  rbac = yamldecode(file("${path.module}/data/rbac.yaml"))
}

locals {
  provider_creds = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)
}

data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = var.secret_manager_creds_name
}

module "provision_users_aws" {
  source            = "./modules/aws"
  users             = local.users["users"]
  rbac              = local.rbac["aws"]["groups"]
}

module "provision_users_gitlab" {
  source       = "./modules/gitlab"
  users        = local.users["users"]
  rbac         = local.rbac["gitlab"]
  gitlab_token = local.provider_creds["gitlab"]["access_token"]
}