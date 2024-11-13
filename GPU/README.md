# EKS GPU Slicing with NVIDIA A100 and Karpenter Integration

This guide outlines the setup for GPU slicing on Amazon EKS with NVIDIA A100 GPUs or other MIG-compatible models, such as A10 and A30. This setup uses Multi-Instance GPU (MIG) technology, enabling efficient resource sharing by splitting a single GPU across multiple workloads. Karpenter integration allows dynamic provisioning of GPU nodes based on real-time demand.

---

## Table of Contents
1. [Confirm MIG-Compatible GPUs on EKS Nodes](#1-confirm-mig-compatible-gpus-on-eks-nodes)
2. [Install NVIDIA's Device Plugin and Enable MIG Mode](#2-install-nvidias-device-plugin-and-enable-mig-mode)
3. [Define GPU Resource Requests in Pods](#3-define-gpu-resource-requests-in-pods)
4. [Integrate GPU Provisioning with Karpenter](#4-integrate-gpu-provisioning-with-karpenter)
5. [Deploy Workloads with Node Selectors and Tolerations](#5-deploy-workloads-with-node-selectors-and-tolerations)
6. [Additional Notes](#additional-notes)

---

## 1. Confirm MIG-Compatible GPUs on EKS Nodes

Ensure your EKS nodes are using NVIDIA GPUs compatible with MIG, such as the A100, A10, or A30. AWS instance types like `p4d` and `g5` support GPU slicing, enabling multiple workloads to share a single GPU and thereby optimize GPU utilization.

## 2. Install NVIDIA's Device Plugin and Enable MIG Mode

Install the NVIDIA device plugin on your EKS cluster to manage GPU resources:

```bash
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/nvidia-device-plugin.yml
```

For MIG compatibility, configure the plugin by setting MIG_STRATEGY=single to enable partitioning of the GPU into different profiles, such as 1/7th of an A100 GPU. This allows multiple pods to share portions of a single GPU.

## 3. Define GPU Resource Requests in Pods

When deploying GPU workloads, specify the GPU resources required by each pod. For example, to use a specific fraction of the GPU (like 1/7 of an A100), specify this in the resources section of your pod’s configuration:

```
yaml

resources:
  limits:
    nvidia.com/mig-1g.5gb: 1
```

This configuration allows each pod to utilize only a portion of the GPU, improving cost efficiency and resource distribution.

## 4. Integrate GPU Provisioning with Karpenter
Configure Karpenter to manage GPU nodes with slicing support by defining a provisioner specific to sliced GPU resources.

Example Provisioner Configuration

```
yaml

apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: gpu-slicing
spec:
  ttlSecondsAfterEmpty: 300
  requirements:
    - key: "nvidia.com/gpu"
      operator: In
      values: ["a100", "a10"]
    - key: "karpenter.sh/capacity-type"
      operator: In
      values: ["spot", "on-demand"]
  provider:
    subnetSelector:
      karpenter.sh/discovery: ${CLUSTER_NAME}
```

With this setup, Karpenter can autoscale GPU-sliced nodes and use taints and labels for more controlled scheduling of workloads.

## 5. Deploy Workloads with Node Selectors and Tolerations

To ensure GPU workloads run only on nodes with sliced GPU resources, add nodeSelector and tolerations to your pod specifications:

```
yaml

spec:
  tolerations:
    - key: "nvidia.com/gpu-shared"
      operator: "Exists"
  nodeSelector:
    nvidia.com/gpu: "a100"
```

This configuration lets workloads specifically target nodes with GPU slicing capabilities, while Karpenter dynamically scales nodes based on workload demand.
