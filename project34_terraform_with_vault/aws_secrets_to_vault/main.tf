#it is necessary to set up env vars before run the project:
#TF_VAR_aws_access_key - The AWS Access Key
#TF_VAR_aws_secret_key - The AWS Secret Key
#VAULT_ADDR - The HashiCorp Vault server address (.i.e. - http://127.0.0.1:8200)
#VAULT_TOKEN - The Root Token which we have generated when starting the HashiCorp Server.
#main source of the script: https://jhooq.com/hashi-vault-aws-secret-terraform/#4-add-aws-secrets-inside-hashicorp-vault
# and https://medium.com/@mitesh_shamra/terraform-security-using-vault-ed0fa1db4e09

#the main reason of doing this is creation of role in Vault and granting access to the role for execution other terraform scrips.
# In this case it is not necessary to share aws keys with other people, just granting access to Vault managed creds.

# For more security tfstate file of current folder can be stored remotely, f.e. in some S3 bucket:
# provider "aws" {
#   region = "eu-central-1"
# }
# terraform {
#   backend "s3" {
#     bucket = "QQQ-terraform-remote-state"   #bucket for terraform state file
#     key    = "dev/terraform.tfstate"        #remote path of the file
#     region = "eu-central-1"                 #region where the bucket is created
#   }
# }

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
