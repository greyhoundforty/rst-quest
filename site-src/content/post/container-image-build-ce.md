---
author: "Ryan Tiffany"
title: "Container image builds using IBM Code Engine"
date: "2021-03-05"
description: "Build a container image from source control using IBM Cloud Code Engine."
tags:
- code-engine
- serverless
- containers
categories:
- ibmcloud
---

## Overview

This guide will show you how to use the experimental [IBM Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-about) to build a container image from a Source control repository. Behind the scenes Code Engine will use [Tekton](https://tekton.dev/) pipelines to pull our source code from a Github repository and then create a container image using the supplied Docker file. After the build is complete Code Engine will push the new container image in to the [IBM Cloud Container Registry](https://cloud.ibm.com/docs/Registry?topic=Registry-registry_overview).

**NOTE**: Code Engine is currently an experimental offering and all resources are deleted every 7 days.

## Start a session in IBM Cloud Shell

In the IBM Cloud console, click the IBM Cloud Shell icon 

![Cloud Shell Icon](https://dsc.cloud/quickshare/Shared-Image-2020-09-23-09-26-23.png). 

A session starts and automatically logs you in through the IBM Cloud CLI. 

## Target Resource Group
In oder to interact with the Code Engine CLI we first need to target the Resource Group where the Code Engine project will be created:

```shell
$ ibmcloud target -g <Your Resource Group>
```

## Create a Code Engine Project
The first step is to create a Code Engine project. 

> Keep in mind during the Beta phase you are limited to one Code Engine project per region. If you already have a Code Engine project you can simply target that project using the command `ibmcloud ce project target -n <name of project>`  

We'll specify the `--target` option to automatically have the Code Engine cli target our new project:

```
$ ibmcloud ce project create -n <Project Name> --target
```

The project creation can take a few minutes, but when it completes you should see something like this:

```shell 
$ ibmcloud ce project create -n ce-demo-project --target
Creating project 'ce-demo-project'...
Waiting for project 'ce-demo-project' to be in ready state...
Now selecting project 'ce-demo-project'.
OK
```

## Create an API Key for Code Engine for Registry Access
As part of our Build process we are going be pulling a public Github repo but then pushing the built container in to [IBM Cloud Container Registry](https://cloud.ibm.com/docs/Registry?topic=Registry-registry_overview). In order for our Code Engine project to be able to push to the registry we'll need to create an API key. 

```shell
$ ibmcloud iam api-key-create <Project Name>-cliapikey -d "API Key for talking to Image registry from Code Engine" --file key_file
```

## Create Code Engine Registry Secret
With our API key created, we will now add the IBM Cloud Container Registry to Code Engine. When using the IBM Container Registry the username will always be `iamapikey`. If you would like to push to an alternate IBM Container Registry [endpoint](https://cloud.ibm.com/docs/Registry?topic=Registry-registry_overview#registry_regions_local) update the `--server` flag accordingly. 

```shell
$ export CR_API_KEY=`jq -r '.apikey' < key_file`

$ ibmcloud ce registry create --name ibmcr --server us.icr.io --username iamapikey --password "${CR_API_KEY}"
```

You can view all of your registry secrets by running the command: `ibmcloud ce registry list`.

```shell
$ ibmcloud ce registry list 
Project 'demo-rt' and all its contents will be automatically deleted 7 days from now.
Listing image registry access secrets...
OK

Name   Age  
ibmcr  11s
```

## Create Code Engine Build Definition 
With the Registry access added we can now create our Build definition. If you do not already have a Container namespace to push images to, please follow [this guide to create one. 

```shell
$ ibmcloud ce build create --name go-app-example-build --source https://github.com/greyhoundforty/ce-build-example-go --strategy kaniko --size medium --image us.icr.io/<namespace>/go-app-example --registry-secret ibmcr
```

**The breakdown of the command:**
 - name: The name of the build definition 
 - source: The Source control repository where our code lives
 - strategy:  The [build strategy](https://cloud.ibm.com/docs/codeengine?topic=codeengine-plan-build#build-strategy)  we will use to build the image. In this case since our repository has a Dockerfile we will use `kaniko`
 - size: The size of the build defines how CPU cores, memory, and disk space are assigned to the build
 - image: The Container Registry namespace and image name to push our built container image
 - registry-secret: The Container Registry secret that allows Code Engine to push and pull images

## Submit the Build Job 
Before the Build run is submitted (the actual process of building the container image), we’ll want to target the underlying Kubernetes cluster that powers Code Engine. This will allow us to see the pods that are spun up for the build as well as track it’s progress. To have `kubctl` within Cloud Shell target our cluster run the following command: `ibmcloud ce project target -n <Name of Project> -k`  

You should see output similar to this:
```shell
$ ibmcloud ce project target -n demo-rt -k 
Selecting project 'demo-rt'...
Added context for 'demo-rt' to the current kubeconfig file.
OK
```

With `kubectl` properly configured we can now launch the actual build of our container image using the `buildrun` command. We specify the build definition we created previously with the `--build` flag:

```shell
$ ibmcloud ce buildrun submit --name go-app-buildrun-v1 --build go-app-example-build
```
  
You can check the status of the build run using the command `ibmcloud ce buildrun get --name <Name of build run>`

```shell
$ ibmcloud ce buildrun get --name go-app-buildrun-v1
Project 'demo-rt' and all its contents will be automatically deleted 7 days from now.
Getting build run 'go-app-buildrun-v1'...
OK

Name:          go-app-buildrun-v1
ID:            d378e865-ecf4-4e26-932d-acb437eef0ef
Project Name:  demo-rt
Project ID:    ab07a001-9a77-4fd8-82e8-d4f8395ad735
Age:           36s
Created:       2020-09-23 09:13:33 -0500 CDT
Status:
  Reason:      Running
  Registered:  Unknown

Instances:
  Name                                Running  Status   Restarts  Age
  go-app-buildrun-v1-xpqfq-pod-hqchd  2/4      Running  0         34s
```

You can also check on the status of the Kubernetes pods by running `kubectl get pods`

```shell
$ kubectl get pods
NAME                                 READY   STATUS      RESTARTS   AGE
go-app-buildrun-v1-xpqfq-pod-hqchd   2/4     Running     0          41s
```

If the build completes successfully the pods will show `Completed` and the build run will show `Succeeded`

```shell 
$ kubectl get pods
NAME                                 READY   STATUS      RESTARTS   AGE
go-app-buildrun-v1-xpqfq-pod-hqchd   0/4     Completed   0          4m10s

$ ibmcloud ce buildrun get --name go-app-buildrun-v1
Project 'demo-rt' and all its contents will be automatically deleted 7 days from now.
Getting build run 'go-app-buildrun-v1'...
OK

Name:          go-app-buildrun-v1
ID:            d378e865-ecf4-4e26-932d-acb437eef0ef
Project Name:  demo-rt
Project ID:    ab07a001-9a77-4fd8-82e8-d4f8395ad735
Age:           4m26s
Created:       2020-09-23 09:13:33 -0500 CDT
Status:
  Reason:      Succeeded
  Registered:  True

Instances:
  Name                                Running  Status     Restarts  Age
  go-app-buildrun-v1-xpqfq-pod-hqchd  0/4      Succeeded  0         4m24s
```