# it takes credentials from Vault

provider "vault" {
}

data "vault_aws_access_credentials" "creds" {
  backend = "dynamic-aws-creds-vault-admin-path"
  role    = "dynamic-aws-creds-vault-admin-role"
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region     = "eu-central-1"
}

resource "aws_s3_bucket" "s3-bucket-vault-terraform" {
  bucket        = "s3-bucket-vault-terraform"
  force_destroy = true
}
resource "aws_s3_object" "object1" {
  for_each = fileset("uploads/", "*")
  bucket   = aws_s3_bucket.s3-bucket-vault-terraform.id
  key      = each.value
  source   = "uploads/${each.value}"
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.s3-bucket-vault-terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "access_key" {
  value = data.vault_aws_access_credentials.creds.access_key
}
