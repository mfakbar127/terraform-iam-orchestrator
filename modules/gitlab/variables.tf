variable "users" {
  description = "List of users with their attributes"
}

variable "gitlab_token" {
  type        = string
  description = "gitlab_token API key"
  sensitive   = true
}

variable "gitlab_base_url" {
  type        = string
  description = "gitlab_base_url"
  default = "http://localhost:8082/"
}

variable "rbac" {
  description = "List of users with their attributes"
}