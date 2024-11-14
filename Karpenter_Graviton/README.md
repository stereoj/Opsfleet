# EKS Cluster Setup with Karpenter and Graviton

This project automates the creation of an EKS cluster on AWS with Karpenter for autoscaling and support for Graviton instances. 

## Prerequisites

- AWS CLI configured with access permissions
- Terraform installed
- Helm installed
- kubectl installed and configured

## Setup Instructions

1. **Clone the Repository**

   ```
   git clone https://github.com/your-repo/eks-cluster-terraform.git
   cd eks-cluster-terraform
   ```

2. **Update Variables**

Update variables.tf with the vpc_id and subnet_ids values of your existing VPC.

3. **Initialize and Apply Terraform**


   ```
   terraform init
   terraform apply
   ```
   
4. **Configure kubectl for EKS Access**

   ```
   aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region us-west-2
   ```

5. **Verify Karpenter Installation**
   
   ```
   kubectl get pods -n karpenter
   ```

## Running a Pod on ARM (Graviton)

To deploy a workload on a specific architecture (x86 or ARM), specify the node selector in your pod definition.

Example Pod for ARM (Graviton) Architecture

```
apiVersion: v1
kind: Pod
metadata:
  name: graviton-pod
spec:
  nodeSelector:
    "kubernetes.io/arch": "arm64"
  containers:
    - name: graviton-container
      image: public.ecr.aws/amazonlinux/amazonlinux:latest
      command: ["sleep", "3600"]
```

Deploy these pods using kubectl:

```
kubectl apply -f graviton-pod.yaml
```
