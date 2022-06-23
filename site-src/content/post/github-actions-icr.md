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

Today I will be showing an example GitHub [Action](https://docs.github.com/en/actions) that will use [Podman][podman] to build and push a container image to the IBM Cloud [Container Registry][icr]. If your container file is not named `Dockerfile`, or is not in the root directory of your repository, update the `containerfiles` section of the yaml file.  

## Prepare Github repository

You will need to add two Action [Secrets][action-secret] for this workflow Action to run correctly.

- **IMAGE_NAME**: The name of the container image. This will be in the form of `namespace/container-image`. Ex: `ryantiffany/nginx`
- **REGISTRY_PASSWORD**: An IBM Cloud [API Key][api-key] that is used to authenticate podman with the container registry service.


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
        registry: ${{ env.REGISTRY_URL }}
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

[podman]: https://podman.io
[icr]: https://cloud.ibm.com/docs/Registry?topic=Registry-registry_overview
[action-secret]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[api-key]: https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui