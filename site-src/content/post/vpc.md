---
author: "Ryan Tiffany"
title: "Using the IBM Cloud VPC CLI Plugin"
date: "2021-03-05"
tags:
- virtual-private-cloud
- cli
categories:
- ibmcloud
---

## Overview

The VPC plugin allows you to interact with your VPCs, Subnets, Gateways, and more that are running in the IBM Cloud. In this guide I will show how to install the plugin and use it to list, query, and interact with the resources that are deployed as part of your Virtual Private Cloud.

> Note: The following examples use [jq][jq] to parse the json output returned by the IBM Cloud CLIs `output` flag. If you do not have jq installed or cannot install it, you can use [IBM Cloud Shell][cloud-shell] which includes `jq` by default.

## Installing the plugin

If the pluging is not already installed you can install it using the following command:

```sh
ibmcloud plugin update vpc-infrastructure
```

To verify the plugin is installed, run the following command: `ibmcloud is regions`. This will list the available regions where VPCs can be deployed.

### VPCs

In order to interact with VPC resources you will need to target a VPC region. For instance if I wanted to look up my VPC resources in the `us-south` region I would set that in the CLI with the following command: `ibmcloud target -r us-south`.

#### List VPCs and return names and IDs

List all of the VPCs in the targetted region and use jq to return just the names and IDs:

```sh
ibmcloud is vpcs --output json | jq -r '.[] | .name, .id'
```

**Example Output**

```sh
ibmcloud is vpcs --output json | jq -r '.[] | .name, .id'

eric-vpxc
r006-5c3fccad-xxxxxxxxxxx
jb-vpc
r006-9aae556c-xxxxxxxxxxx
khurst
r006-f4aaa5ad-xxxxxxxxxxx
normangen2
r006-d9316884-xxxxxxxxxxx
russelldallastest
r006-65c1d331-xxxxxxxxxxx
russellmigtest
r006-ddf4d12f-xxxxxxxxxxx
```

## Subnet

### Get all Subnets in a VPC and return their ID and Name

- VPC_NAME: The name of the VPC where the subnets reside

```shell
ic is subnets --output json | jq -r '.[] | select(.vpc.name=="VPC_NAME") | .name,.id'
```

## Images

### Import custom image in to VPC
 
> - CUSTOM_IMAGE_NAME: The name assigned to the imported image  
> - IMAGE: The file name of the `qcow2` image  
> - OS_NAME: The IBM Cloud equivalent OS Name. See [here](#finding-ibm-image-os-names) for supported options.  
> - RESOURCE_GROUP_ID: The resource group ID for the imported image

```sh
ibmcloud is image-create CUSTOM_IMAGE_NAME --file cos://region/bucket/IMAGE --os-name OS_NAME --resource-group-id RESOURCE_GROUP_ID
```

## Instances 
Examples for interacting with VPC compute instances

### Get Windows instance password

 - INSTANCE_ID: The compute instance ID

```shell
ibmcloud is instance-initialization-values INSTANCE_ID --private-key @/path/to/private_key
```

### Get primary IP from instance 
 - INSTANCE_ID: The compute instance ID

```shell
ibmcloud is instance INSTANCE_ID --json | jq -r '.primary_network_interface.primary_ipv4_address'
```

### Grab ID of compute instance based on name
 - NAME_OF_INSTANCE: The name of the compute instance

```shell
ibmcloud is instances --output json | jq -r '.[] | select(.name=="NAME_OF_INSTANCE") | .id'
```

### Find all networking interfaces attached to instance and return their name and ID
 - INSTANCE_ID: The compute instance ID

```shell
ibmcloud is in-nics INSTANCE_ID --output json | jq -r '.[] | .name,.id'
```

### Find the floating IP attached to a specific compute instance
 - INSTANCE_ID: The compute instance ID

```shell
ibmcloud is instance INSTANCE_ID --output json | jq -r '.network_interfaces[].floating_ips[].id'
```

## Finding Names and IDs

#### Finding IBM Image OS Names
You can run the following command to list the supported OS Names:

```shell
ibmcloud is images --visibility public --json | jq -r '.[] | select(.status=="available") | .operating_system.name'
```

[jq]: https://stedolan.github.io/jq/
[cloud-shell]: https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-getting-started
