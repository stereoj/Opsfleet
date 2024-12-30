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
   git clone https://github.com/stereoj/Opsfleet.git
   cd ./Opsfleet/Karpenter_Graviton
   ```

2. **Initialize, Plan and Apply Terraform**


   ```
   terraform init
   terraform plan
   terraform apply
   ```
   
4. **Configure kubectl for EKS Access**

   ```
   aws eks --region us-east-1 update-kubeconfig --name karpenter-blueprints
   ```

5. **Verify Karpenter Installation**
   
   ```
   kubectl get pods -n karpenter
   ```

## Running a Pod on ARM (Graviton)

To deploy a workload on a specific architecture (x86 or ARM), specify the node selector in your pod definition.

Example Pod for ARM (Graviton) Architecture

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workload-graviton
spec:
  replicas: 5
  selector:
    matchLabels:
      app: workload-graviton
  template:
    metadata:
      labels:
        app: workload-graviton
    spec:
      nodeSelector:
        intent: apps
        kubernetes.io/arch: arm64
      containers:
      - name: workload-flexible
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        imagePullPolicy: Always
        resources:
          requests:
            cpu: 512m
            memory: 512Mi 
```

Deploy these pods using kubectl:

```
kubectl apply -f workload-graviton.yaml
```
