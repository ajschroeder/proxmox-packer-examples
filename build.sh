#!/usr/bin/env bash
clear

export PACKER_LOG=1
export PACKER_LOG_PATH="logs/packerlogs-$(date +"%m_%d_%Y_%H%M").txt"

echo ">Packer Init!"

echo ">Initializing Packer!"
packer init ubuntu24ovmf.pkr.hcl

echo ">Let's get building!"
packer build -force -on-error=ask -var-file vars.pkvars.hcl ubuntu24ovmf.pkr.hcl

