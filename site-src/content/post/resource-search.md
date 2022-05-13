---
author: "Ryan Tiffany"
title: "Resource search using the IBM Cloud CLI"
date: "2022-03-05"
description: "Command line examples for ibmcloud resource search."
tags:
- search
- cli
categories:
- ibmcloud
---

These examples are broken up in to two sections:

- [Cloud](#search-cloud-resources)
- [IaaS (Classic Infrastructure)](#search-classic-infrastructure)

> Note: The following examples use [jq][jq] to parse the json output returned by the IBM Cloud CLIs `output` flag. If you do not have jq installed or cannot install it, you can use [IBM Cloud Shell][cloud-shell] which includes `jq` by default.

## Search Cloud Resources

### Search for resource by name

Search for a cloud resource with the name `devcluster`:

```sh
ibmcloud resource search 'name:devcluster'
```

### Search by resource name and return CRN 

Perform the same search, but use `jq` to just return the CRN of the resource:

```sh
ibmcloud resource search 'name:devcluster' --output json \
    | jq -r '.items[].crn'
```

### Search by resource tag

Search for all cloud resources with the tag `ryantiffany`

```sh
ibmcloud resource search 'tags:ryantiffany' --output json
```

### Search by resource tag and just return resource names

Search for all cloud resources with the tag `env:2022-cde-lab` and return just the items name:

```shell
ibmcloud resource search 'tags:"env:2022-cde-lab"' --output json \
    | jq -r '.items[].name'
```

**Example Output**

```sh
ibmcloud resource search 'tags:"env:2022-cde-lab"' --output json \
    | jq -r '.items[].name'
2022-cde-lab-cos-instance
continuous-delivery-2022-cde-lab
pubgw-au-syd-1-2022-cde-lab
subnet-au-syd-1-2022-cde-lab
pubgw-au-syd-2-2022-cde-lab
subnet-au-syd-2-2022-cde-lab
pubgw-au-syd-3-2022-cde-lab
subnet-au-syd-3-2022-cde-lab
vpc-au-syd-2022-cde-lab
```

### Search by resource tag and return resource type

Find all the cloud resources with the tag `env:2022-cde-lab` and return their resource type:

```shell
ibmcloud resource search 'tags:"env:2022-cde-lab"' --output json \
    | jq -r  '.items[].type'
```

## Search Classic Infrastructure

```shell
ibmcloud resource search -p classic-infrastructure --output json
```

### Search classic infrastructure by tag

```shell
ibmcloud resource search "tagReferences.tag.name:ryantiffany" \
    -p classic-infrastructure --output json
```

### Search classic infrastructure by tag and return resource types

```sh
ibmcloud resource search "tagReferences.tag.name:ryantiffany" \
    -p classic-infrastructure --output json \
    | jq -r '.items[].resourceType'
```

### Search by tag and filter by resource type

Search for resources with the tag `ryantiffany` and use the `_objectType` filter to just return the Classic Virtual Servers:

```shell
ibmcloud resource search "tagReferences.tag.name:ryantiffany \
    _objectType:SoftLayer_Virtual_Guest" \
    -p classic-infrastructure --output json 
```

### Search IaaS Virtual instances by Tag and return FQDNs

Search for resources with the tag `ryantiffany` and use the `_objectType` filter and jq to just return the FQDN of the servers:

```shell
ibmcloud resource search "tagReferences.tag.name:ryantiffany \
    _objectType:SoftLayer_Virtual_Guest" \
    -p classic-infrastructure --output json \
    | jq -r '.items[].resource.fullyQualifiedDomainName'
```

### Search IaaS Virtual instances by Tag and return instance ID's 

```shell
ibmcloud resource search "tagReferences.tag.name:ryantiffany \
    _objectType:SoftLayer_Virtual_Guest" \
    -p classic-infrastructure --output json | jq -r '.items[].resource.id'
```

[jq]: https://stedolan.github.io/jq/
[cloud-shell]: https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-getting-started
