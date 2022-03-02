# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A GKE PUBLIC CLUSTER IN GOOGLE CLOUD PLATFORM WITH AN EXAMPLE CHART USING HELM
# This is an example of how to use the gke-cluster module to deploy a public Kubernetes cluster in GCP with a
# Load Balancer in front of it. This example also deploys a chart using Helm.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A PUBLIC CLUSTER IN GOOGLE CLOUD PLATFORM
# ---------------------------------------------------------------------------------------------------------------------

module "gke_cluster" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-cluster?ref=v0.2.0"
  source = "./modules/gke-cluster"

  name = var.cluster_name

  project  = var.project
  location = var.location

  # We're deploying the cluster in the 'public' subnetwork to allow outbound internet access
  # See the network access tier table for full details:
  # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  network                      = module.vpc_network.network
  subnetwork                   = module.vpc_network.public_subnetwork
  cluster_secondary_range_name = module.vpc_network.public_subnetwork_secondary_range_name

  # To make testing easier, we keep the public endpoint available. In production, we highly recommend restricting access to only within the network boundary, requiring your users to use a bastion host or VPN.
  disable_public_endpoint = "false"

  # add resource labels to the cluster
  resource_labels = {
    environment = "testing"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NODE POOL
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_node_pool" "node_pool" {
  provider = google-beta

  name     = "main-pool"
  project  = var.project
  location = var.location
  cluster  = module.gke_cluster.name

  initial_node_count = "1"

  autoscaling {
    min_node_count = "1"
    max_node_count = "5"
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-1"

    labels = {
      all-pools-example = "true"
    }

    # Add a public tag to the instances. See the network access tier table for full details:
    # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
    tags = [
      module.vpc_network.public,
      "helm-example",
    ]

    disk_size_gb = "30"
    disk_type    = "pd-standard"
    preemptible  = false

    service_account = module.gke_service_account.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# WORKAROUNDS
# ---------------------------------------------------------------------------------------------------------------------

# This is a workaround for the Kubernetes and Helm providers as Terraform doesn't currently support passing in module
# outputs to providers directly.
data "template_file" "gke_host_endpoint" {
  template = module.gke_cluster.endpoint
}

data "template_file" "access_token" {
  template = data.google_client_config.client.access_token
}

data "template_file" "cluster_ca_certificate" {
  template = module.gke_cluster.cluster_ca_certificate
}
