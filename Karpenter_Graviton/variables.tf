variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC for the EKS cluster."
  type        = list(string)
}
