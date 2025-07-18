## Introduction

This repository provides opinionated infrastructure-as-code examples to automate the creation of virtual machine images and their guest operating systems on Proxmox using [HashiCorp Packer][packer] and the [Packer Plugin for Proxmox][packer-plugin-proxmox] (`proxmox-iso` builder). All examples are authored in the HashiCorp Configuration Language ("HCL2").

By default, the machine image artifacts are converted to templates within Proxmox after a virtual machine is built and configured according to the individual templates.

These templates are specifically built for usage with Terraform deployments via cloud-init.

## Instructions

1. Copy the variables file and fill it in with your appropriate information
       command:  `cp Ubuntu24/vars.pkvars.pkr.hcl.example Ubuntu24/vars.pkvars.pkr.hcl`
2. Copy the user-data file and fill it in with your appropriate information
       command: `cp Ubuntu24/http/user-data.example Ubuntu24/http/user-data`
3. cd into the Ubuntu24 directory `cd Ubuntu24/` 
4. run Ubuntu24/build.sh, the default is for a UEFI based image
       For a seabios based template, run `build.sh bios`
       Otherwise, just run `build.sh`

## Opinionated selections
This image install Docker via the [Traefikturkey Onramp Docker install playbook](https://github.com/traefikturkey/onramp/blob/master/ansible/install-docker.yml)

## Terraform example
A working Terraform example is provided for a uefi based clone of the OFMF/UEFI template

## Upcoming
Refer to [Issues](https://github.com/traefikturkey/proxmox-packer-examples/issues) for bugs, upcoming features, etc.