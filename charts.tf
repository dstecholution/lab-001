# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SAMPLE CHART
# A chart repository is a location where packaged charts can be stored and shared. Define Bitnami Helm repository location,
# so Helm can install the nginx chart.
#
# We also install sysdig, gremlind, and opa gatekeeper
# ---------------------------------------------------------------------------------------------------------------------

#resource "helm_release" "_name_" {
#  depends_on = [google_container_node_pool.node_pool]
#  
#  repository = "https://_repo_"
#  name       = "_name_"
#  chart      = "_name_"
#  create_namespace = true
#  namespace  = "_namespace_"
#}

# Prevents misconfig and acts as a security tool plus IAM
resource "helm_release" "gatekeeper" {
  depends_on = [google_container_node_pool.node_pool]
  
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  name       = "gatekeeper"
  chart      = "gatekeeper/gatekeeper"
  namespace  = "gatekeeper-system"
  create_namespace = true
}

resource "helm_release" "sysdig" {
  depends_on = [google_container_node_pool.node_pool]

  repository = "https://charts.sysdig.com/"
  name       = "sysdig"
  chart      = "sysdig"

  namespace  = "sysdig-agent"
  create_namespace = true

  set {
    name = "sysdig.accessKey"
    value = var.sysdig_accessKey
  }

  set {
    name = "sysdig.settings.collector"
    value = var.sysdig_collector
  }

  set {
    name = "sysdig.settings.collector_port"
    value = var.sysdig_collector_port
  }

  set {
    name = "nodeAnalyzer.apiEndpoint"
    value = var.sysdig_collector
  }

}

## Chaos Agent
resource "helm_release" "gremlind" {
  depends_on = [google_container_node_pool.node_pool]
  
  repository = "https://helm.gremlin.com"
  name       = "gremlin"
  chart      = "gremlin/gremlin"
  namespace  = "gremlin"
  create_namespace = true

  set {
    name = "gremlin.secret.managed"
    value = "true"
  }

  set {
    name = "gremlin.secret.type"
    value = "secret"
  }

  set {
    name = "gremlin.secret.teamID"
    value = var.gremlin_teamID
  }

  set {
    name = "gremlin.secret.clusterID"
    value = var.gremlin_clusterID
  }

  set {
    name = "gremlin.secret.teamSecet"
    value = var.gremlin_teamSecet
  }

}

resource "helm_release" "nginx" {
  depends_on = [google_container_node_pool.node_pool]

  repository = "https://charts.bitnami.com/bitnami"
  name       = "nginx"
  chart      = "nginx"

}
