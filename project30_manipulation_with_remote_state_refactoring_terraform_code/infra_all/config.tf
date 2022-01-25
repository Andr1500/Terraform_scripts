terraform {
  backend "s3" {
    bucket = "a1500-terraform-remote-state" #bucket for terraform state file
    key    = "infra_all/terraform.tfstate"  #object name in the bucket to save terraform file
    region = "eu-central-1"                 #region where bucket is created
  }
}
