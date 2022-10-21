#if is necessary to set up env vars before run the project:
#TF_VAR_aws_access_key - The AWS Access Key
#TF_VAR_aws_secret_key - The AWS Secret Key
#VAULT_ADDR - The HashiCorp Vault server address (.i.e. - http://127.0.0.1:8200)
#VAULT_TOKEN - The Root Token which we have generated when starting the HashiCorp Server.
#main source of the script: https://jhooq.com/hashi-vault-aws-secret-terraform/#4-add-aws-secrets-inside-hashicorp-vault

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "name" { default = "dynamic-aws-creds-vault-admin" }

provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  path       = "${var.name}-path"
  region     = "eu-central-1"

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds     = "240"
}

resource "vault_aws_secret_backend_role" "admin" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "${var.name}-role"
  credential_type = "iam_user"

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*", "ec2:*", "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "backend" {
  value = vault_aws_secret_backend.aws.path
}

output "role" {
  value = vault_aws_secret_backend_role.admin.name
}
