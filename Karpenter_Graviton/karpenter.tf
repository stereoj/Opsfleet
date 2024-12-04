# Add Helm provider to install Karpenter
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.36.2"

  set {
    name  = "controller.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "controller.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "karpenter-service-account"
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${var.aws_account_id}:role/KarpenterControllerRole"
  }
}
