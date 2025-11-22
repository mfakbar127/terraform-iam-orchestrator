# Terraform IAM Orchestrator

Centralized user access management for SaaS platforms using Terraform and YAML.

## Overview

This project automates user provisioning and access control across multiple SaaS platforms using a single source of truth. Define users and their permissions once in YAML files, and Terraform handles the rest.

**Current Implementation:** AWS IAM and GitLab (extensible to other SaaS platforms)

**Blog Post:** [Centralizing User Access Management Using Terraform for SaaS Applications — Part 1](https://medium.com/@mf-akbar/centralizing-user-access-management-using-terraform-for-saas-applications-part-1-8bb7d8dc3faa)

## Features

- **Centralized User Management**: Define all users in `data/users.yaml`
- **RBAC Configuration**: Role-based access control via `data/rbac.yaml`
- **Multi-Platform Support**: Extensible framework (AWS IAM and GitLab included)
- **Secure Credentials**: Uses AWS Secrets Manager for sensitive data
- **State Management**: S3 backend with DynamoDB locking

## Project Structure

```
.
├── data/
│   ├── users.yaml       # User definitions and assignments
│   └── rbac.yaml        # Role and policy definitions
├── modules/
│   ├── aws/             # AWS IAM user and group management
│   ├── gitlab/          # GitLab user and group management
│   └── [other-saas]/    # Add modules for other platforms
└── main.tf              # Root module configuration
```

## Quick Start

1. **Configure Users** (`data/users.yaml`):
```yaml
users:
  - username: "john.doe"
    gitlab:
      group: ["devops::reporter", "security::maintainer"]
      state: active
    aws:
      path: "/"
      group: [Security]
    user_info:
      name: "John Doe"
      email: "john.doe@example.com"
```

2. **Define RBAC Policies** (`data/rbac.yaml`):
```yaml
aws:
  groups:
    - name: Security
      policies: [arn:aws:iam::aws:policy/SecurityAudit]
gitlab:
  groups: ["devops", "security"]
```

3. **Store Credentials in AWS Secrets Manager**:
```json
{
  "gitlab": {
    "access_token": "your-token-here"
  }
}
```

4. **Deploy**:
```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials (for AWS IAM module)
- GitLab access token stored in AWS Secrets Manager (for GitLab module)
- S3 bucket and DynamoDB table for state management

**Note:** Requirements vary based on which SaaS platforms you're integrating. The above are for the included AWS and GitLab modules.

## Configuration

Update the backend configuration in `main.tf`:
```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "iam/terraform.tfstate"
  region         = "us-east-2"
  dynamodb_table = "terraform-lock-table"
  encrypt        = true
}
```

## License

MIT
