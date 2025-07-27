#!/usr/bin/env bash
clear

if [$1 -eq "bios"]; then
    export PACKERFILE="ubuntu24bios.pkr.hcl"
else 
    export PACKERFILE="ubuntu24ovmf.pkr.hcl"
fi

export PACKER_LOG=1
export PACKER_LOG_PATH="logs/packerlogs-$(date +"%m_%d_%Y_%H%M").txt"
echo ">Packer Init!"

echo ">Initializing Packer!"
packer init $PACKERFILE

echo ">Let's get building!"
packer build -force -on-error=ask -var-file vars.pkvars.hcl $PACKERFILE

