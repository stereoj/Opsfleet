# Add Helm provider to install Karpenter
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.20.0"  # Check for the latest version

  set {
    name  = "controller.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "controller.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
}
