terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.6.1"
    }
  }
}

provider "mongodbatlas" {
  public_key  = "public_key"
  private_key = "private_key"
}

module "cluster" {
  source       = "./modules/cluster"
  region       = var.region
  cluster_name = var.cluster_name
  cluster_size = var.cluster_size
  project_id   = var.project_id
}
