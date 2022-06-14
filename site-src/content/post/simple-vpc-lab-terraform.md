---
author: "Ryan Tiffany"
title: "Create a simple VPC for lab testing on IBM Cloud"
date: "2022-06-12"
draft: true
tags:
- vpc
- terraform
categories:
- ibmcloud
---


In this guide I will show you how to deploy a simple VPC environment on IBM Cloud using Terraform. This is the same environment that I use for a lot of my testing or demo labs at work. The lab environment consists of the following components:

 - IBM Cloud VPC (with default address prefixes across 3 zones)
    - A Public Gateway in a single zone.
    - A frontend and backend subnet in a single zone.
    - VPC [Flowlog](https://cloud.ibm.com/docs/vpc?topic=vpc-flow-logs) collectors for frontend and backend subnets.
 - IBM Cloud Object Storage instance.
    - A regional bucket for both frontend and backend subnet flowlogs.
 - (Optional) IBM Cloud [Monitoring](https://cloud.ibm.com/docs/monitoring?topic=monitoring-about-monitor) instance.
 - (Optional) IBM Cloud Log Analysis instance.
 - (Optional) IBM Cloud Data Engine (formerly SQL Query). This will allow you to run [SQL type queries](https://cloud.ibm.com/docs/vpc?topic=vpc-fl-analyze) against the flowlogs in our Object Storage buckets.

![](https://dsc.cloud/quickshare/lab-vpc.png)

## Deploy VPC Resources

To get started, we will clone the example repository and initialize our Terraform directory:

1. 
    
    ```sh
    git clone https://github.com/cloud-design-dev/ibmcloud-vpc-packer
    cd ibmcloud-vpc-packer/base-vpc
    ```

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:

   ```sh
   cp terraform.tfvars.example terraform.tfvars
   ```

1. Edit `terraform.tfvars` to match your environment. See [inputs](#inputs) for available options.
1. Plan deployment:

   ```sh
   terraform init
   terraform plan -out default.tfplan
   ```

1. Apply deployment:

   ```sh
   terraform apply default.tfplan
   ```
