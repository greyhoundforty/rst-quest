---
author: "Ryan Tiffany"
title: "Using the Object Storage CLI Plugin"
date: "2021-03-05"
description: "Example uses for the IBM Cloud COS plugin."
tags:
- object-storage
- cli
categories:
- ibmcloud
---

# Overview
Examples of interacting with the IBM Cloud Object Storage CLI Plugin. 

## Prerequisites
Requires the [cos](https://cloud.ibm.com/docs/cli?topic=cloud-object-storage-cli-plugin-ic-cos-cli#ic-installation) plugin to be installed. 

## Configure `cos` plugin to use your object storage instance
 - NAME_OF_COS_INSTANCE: The name of the existing Object Storage instance to interact with

```shell
ibmcloud cos config crn --crn $(ibmcloud resource service-instance NAME_OF_COS_INSTANCE --output json | jq -r '.[].id')
```

## Upload object to object storage bucket
```shell
ibmcloud cos upload --bucket NAME_OF_BUCKET --key NAME_FOR_OBJECT \
--file /path/to/object --region ICOS_REGION
```

## Create HMAC credentials for S3 clients
```shell
ibmcloud resource service-key-create NAME_OF_SERVICE_KEY Writer --instance-name NAME_OF_COS_INSTANCE --parameters '{"HMAC":true}'
```