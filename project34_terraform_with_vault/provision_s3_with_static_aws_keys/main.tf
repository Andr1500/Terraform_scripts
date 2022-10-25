#necessary to add aceess and secret access keys into Vault (create the secrets manually)

terraform {
  required_providers {
    aws = {
    }
    vault = {
    }
  }
}

data "vault_generic_secret" "aws_creds" {
  path = "cubbyhole/aws"
}

provider "aws" {
  region     = data.vault_generic_secret.aws_creds.data["aws_region"]
  access_key = data.vault_generic_secret.aws_creds.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_creds.data["AWS_SECRET_ACCESS_KEY"]
}

resource "aws_s3_bucket" "s3-bucket-vault-terraform" {
  bucket        = "s3-bucket-vault-terraform_staticcreds"
  force_destroy = true
}
