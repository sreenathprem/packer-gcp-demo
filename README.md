# Packer GCP Demo

This project shows a basic demo of HCP Packer + HCP Terraform on GCP

## Initialize HCP Packer

1. Set the following environment variables

```
HCP_CLIENT_ID
HCP_CLIENT_SECRET
HCP_PROJECT_ID
```
2. Adjust the variables in the `variables.auto.pkrvars.hcl`

3. Do a packer build
```
packer build .
```
This would create the bucket and push a version to it in your HCP Packer Registry.

## Initialize HCP Terraform

A sample TF configuration for using the Packer buckets is present under the `vm` folder
1. Create a TFC workspace where the TF code can run. 
Refer to [this](https://github.com/hashicorp/terraform-dynamic-credentials-setup-examples) repo for quickly bootstrapping TFC workspaces with dynamic credentials
Also use the hcp scripts in that repo for establishing trust between HCP Terraform and HCP Packer

2. Attach the HCP Packer Runtask to your workspace. [Relevant Docu](https://developer.hashicorp.com/packer/tutorials/hcp/setup-hcp-terraform-run-task)

3. Trigger a Run. The Run Task should evaluate the Packer image that is being used. For VMs that are not using Packer, you should receive a warning.

## Github Actions
An actions pipeline is present in this repo that triggers the packer build and pushes the image metadata to Packer.