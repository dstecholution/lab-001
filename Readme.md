# Lunch and learn Lab 001

## Goals
Create a base lab environment in GCP for running Gremlin, Sysdig, OPA Gatekeeper
for testing and learning Chaos Engineering.

## Slidedeck
 * [Google
   Slides](https://docs.google.com/presentation/d/13GOohknflbFLbFMHme0h2eydzyQuAqdFpohduUPaDnE/edit?usp=sharing)

## Launch in Google Cloud Shell
 * [Open in cloud shell](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fdstechnolution%lab-001.git&cloudshell_git_branch=main&cloudshell_tutorial=README.md)

## Tooling

  * [Snyk](https://app.snyk.io/org/dstechnolution/project/31e8d057-ef22-46d4-923a-8cde342dd4da)
    provides security scanning, secret scanning, policy as code tests, CVE
    scanning, Licence checks, Dependancy/Version Management, and code scanning
  * [Sysdig](https://app.us4.sysdig.com/secure/) is SEIM and HIDS
  * [Gremlin](https://app.gremlin.com/reports/company) is our Chaos Engineering
    agent for fuzzy testing
  * Disaster Recover is handled by treating the cluster as an ephemeral
    appliance and source of truth is the git repo and helm charts
  * [Terraform Cloud](https://app.terraform.io/app/Techolution/workspaces/lab-001)
    is our GitOps workflow for managing deployments of IaC and Applications via
    Helm charts
  * [GKE](https://cloud.google.com/kubernetes-engine) is our cloud of choice.

## Variables

Some services would need to be setup before hand then one needs to pass these
along as terraform varables

Name | Description
-|-
TF_VAR_sysdig_accessKey | Used by sysdig to identify & collector access
TF_VAR_gremlin_teamID | Used by gremlin to identify the team(org.)
TF_VAR_gremlin_clusterID | Generic name for your cluster; could match GCP project name
TF_VAR_gremlin_teamSecret | Gremlin Access key
