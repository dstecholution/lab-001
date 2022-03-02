terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.43.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.1.1"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  project = var.project
  region  = var.region

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google-beta" {
  project = var.project
  region  = var.region

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "client" {}

# Use this datasource to access the Terraform account's email for Kubernetes permissions.
data "google_client_openid_userinfo" "terraform_user" {}

provider "kubernetes" {

  load_config_file       = false
  host                   = data.template_file.gke_host_endpoint.rendered
  token                  = data.template_file.access_token.rendered
  cluster_ca_certificate = data.template_file.cluster_ca_certificate.rendered
}

provider "helm" {

  kubernetes {
    host                   = data.template_file.gke_host_endpoint.rendered
    token                  = data.template_file.access_token.rendered
    cluster_ca_certificate = data.template_file.cluster_ca_certificate.rendered
    load_config_file       = false
  }
}
