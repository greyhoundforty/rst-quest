---
author: "Ryan Tiffany"
title: "Deploy a Warpspeed VPN Server to IBM Cloud VPC using Packer and Terraform"
date: "2022-06-14"
draft: true
tags:
- packer
- terraform
categories:
- ibmcloud
---

In my [previous post][previous-post] I outlined how to use Packer with IBM Cloud to build golden images for our VPC. In this post I will be using Packer and [Terraform][terraform] to build and deploy a [Warpspeed VPN][warpspeed] server in to a new VPC.

## Pre-requisites

- Terraform [installed][tf-install]
- Packer [installed][packer-install]
- IBM Cloud API Key. You can use this [guide][api-key-guide] if you need to create an API key for this tutorial.

## Create our VPC Lab using Terraform

TO get started, we will clone the example repository and initialize our Terraform directory:

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

You should get some output that looks similiar to this:

```

```


### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name that will be prepended to all deployed resources. | `string` | n/a | yes |
| region | IBM Cloud VPC region for deployed resources. | `string` | n/a | yes |
| resource\_group | Name of the Resource Group to use for deployed resources. | `string` | n/a | yes |
| existing\_ssh\_key | The name of an existing VPC SSH Key that will be added to the Warpspeed instance. If none provided, one will be created for us. | `string` | n/a | no |



## Build Warpspeed Compute Image


The first thing we need to do is export a few Environment Variables for Terraform and Packer:

```shell
export IBMCLOUD_API_KEY="Your IBM Cloud API Key"
export IBMCLOUD_REGION="The VPC region where resources will be deployed"
```


---
[previous-post]: https://rst.quest/post/ibmcloud-packer/
[terraform]: https://www.terraform.io
[warpspeed]: https://bunker.services/products/warpspeed
[tf-install]: https://www.terraform.io/downloads
[packer-install]: https://www.packer.io/downloads
[api--guide]: https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key