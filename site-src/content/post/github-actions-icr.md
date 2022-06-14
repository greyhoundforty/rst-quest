---
author: "Ryan Tiffany"
title: "GitHub Action to build and push container to IBM Cloud Registry"
date: "2022-06-11"
draft: true
tags:
- github
- registry
categories:
- ibmcloud
---

Today I will be using GitHub [Actions](https://docs.github.com/en/actions) and [Podman][podman] to build and push a container image to the IBM Cloud [Container Registry][icr]. GitHub Actions is a CI/CD platform for automating the building, testing, and deployment of code. A repository can have multiple Action `workflows` and can handle things like:

- Run integration tests on every pull request
- Add labels new newly opened issues
- Deploy all merged PRs to production
- Build container images/release packages

In our case the action will containerize our simple `go` app when we push changes to the main branch of the repository.

## The Action Workflow

Here is the workflow file for our example repository. It uses podman to build our container image and tags it with `latest` as well as the GitHub commit SHA that triggered the workflow.

```yaml
name: Use Podman to build and push container image to IBM Cloud Registry

on:
  - push
env:
  GITHUB_SHA: ${{ github.sha }}
  REGISTRY_URL: us.icr.io

jobs:
  build-push-update:
    name: Build image
    runs-on: ubuntu-latest

    steps:
    - name: Clone the repository
      uses: actions/checkout@v2

    - name: Buildah Action
      id: build-image
      uses: redhat-actions/buildah-build@v2
      with:
        image: ${{ secrets.IMAGE_NAME }}
        tags: latest ${{ github.sha }}
        containerfiles: |
          ./Dockerfile

    - name: Log in to the IBM Cloud Container registry
      uses: redhat-actions/podman-login@v1
      with:
        registry: ${{ env.REGISTRY }}
        username: iamapikey
        password: ${{ secrets.REGISTRY_PASSWORD }}

    - name: Push to IBM Cloud Container Repository
      id: push-to-icr
      uses: redhat-actions/push-to-registry@v2
      with:
        image: ${{ steps.build-image.outputs.image }}
        tags: ${{ steps.build-image.outputs.tags }}
        registry: ${{ env.REGISTRY }}

    - name: Print image url
      run: echo "Image pushed to ${{ steps.push-to-icr.outputs.registry-paths }}"
```

## Prepare Github
Click [here](https://github.com/cloud-design-dev/icr-github-action-example/fork) to fork the example repository to your Github account. Once that is done you will need to add two Action [Secrets][action-secret] to the respository for proper Authentication with the container registry.

- **IMAGE_NAME**: The name of the container image. This will be in the form of `namespace/container-image`. Ex: `ryantiffany/nginx`
- **REGISTRY_PASSWORD**: An IBM Cloud [API Key] that is used to authenticate podman with the container registry service.

To add the secrets:

- From the main page of the repository, click *Settings*

![](https://dsc.cloud/quickshare/repo-actions-settings.png)

- On the left hand navigation, expand the *Secrets* menu and click *Actions*
- Click *New repository secret* and add the `IMAGE_NAME` secret.
- Repeat the process to add the `REGISTRY_PASSWORD` secret as well.

With the Secrets added to your repository, let's clone the . 


[podman]: https://podman.io
[icr]: https://cloud.ibm.com/docs/Registry?topic=Registry-registry_overview
[action-secret]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository