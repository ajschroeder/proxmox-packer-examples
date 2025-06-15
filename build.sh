#!/usr/bin/env bash

set -e

source common.sh

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: script.sh [OPTIONS] [CONFIG_PATH]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message and exit."
  echo "  -d, --debug   Run builds in debug mode."
  echo ""
  echo "Arguments:"
  echo "  CONFIG_PATH   Path to the configuration directory."
  echo ""
  echo "Examples:"
  echo "  ./build.sh"
  echo "  ./build.sh --help"
  echo "  ./build.sh --debug"
  echo "  ./build.sh config"
  echo "  ./build.sh us-west-1"
  echo "  ./build.sh --debug config"
  echo "  ./build.sh --debug us-west-1"
  exit 0
fi

if [ "$1" == "--debug" ] || [ "$1" == "-d" ]; then
  debug_mode=true
  debug_option="-debug"
  shift
else
  debug_mode=false
  debug_option=""
fi

SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")

if [ -n "$1" ]; then
  CONFIG_PATH=$(realpath "$1")
else
  CONFIG_PATH=$(realpath "${SCRIPT_PATH}/config")
fi

menu_message="Select a HashiCorp Packer build for Proxmox."

if [ "$debug_mode" = true ]; then
  menu_message+=" \e[31m(Debug Mode)\e[0m"
fi

menu_option_1() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/almalinux/10/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a AlmaLinux 10 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a AlmaLinux 10 Template for Proxmox. ###
  echo "Building a AlmaLinux 10 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_2() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/almalinux/9/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a AlmaLinux 9 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a AlmaLinux 9 Template for Proxmox. ###
  echo "Building a AlmaLinux 9 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_3() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/almalinux/8/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a AlmaLinux 8 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a AlmaLinux 8 Template for Proxmox. ###
  echo "Building a AlmaLinux 8 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_4() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/centos/10-stream/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a CentOS 10 Stream Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a CentOS 10 Stream Template for Proxmox. ###
  echo "Building a CentOS 10 Stream Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_5() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/centos/9-stream/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a CentOS 9 Stream Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a CentOS 9 Stream Template for Proxmox. ###
  echo "Building a CentOS 9 Stream Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_6() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/debian/12/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Debian 12 (Bookworm) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Debian 12 (Bookworm) for Proxmox. ###
  echo "Building a Debian 12 (Bookworm) for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_7() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/debian/11/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Debian 11 (Bullseye) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Debian 11 (Bullseye) for Proxmox. ###
  echo "Building a Debian 11 (Bullseye) for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_8() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/opensuse/leap-15-6/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a OpenSUSE Leap 15.6 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a OpenSUSE Leap 15.6 Template for Proxmox. ###
  echo "Building a OpenSUSE Leap 15.6 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_9() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/opensuse/leap-15-5/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a OpenSUSE Leap 15.5 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a OpenSUSE Leap 15.5 Template for Proxmox. ###
  echo "Building a OpenSUSE Leap 15.5 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_10() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/oracle/9/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Oracle Linux 9 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Oracle Linux 9 Template for Proxmox. ###
  echo "Building a Oracle Linux 9 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_11() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/oracle/8/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Oracle Linux 8 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Oracle Linux 8 Template for Proxmox. ###
  echo "Building a Oracle Linux 8 Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_12() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/rocky/9/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Rocky Linux 9 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Rocky Linux 9 for Proxmox. ###
  echo "Building a Rocky Linux 9 for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_13() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/rocky/8/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Rocky Linux 8 Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Rocky Linux 8 for Proxmox. ###
  echo "Building a Rocky Linux 8 for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_14() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/24-04-lts/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Ubuntu Server 24.04 LTS Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 24.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 24.04 LTS Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_15() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/22-04-lts/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Ubuntu Server 22.04 LTS Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 22.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 22.04 LTS Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_16() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/20-04-lts/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Ubuntu Server 20.04 LTS Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 20.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 20.04 LTS Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_17() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/desktop/11/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build all Windows 11 Templates for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build all Windows 11 Templates for Proxmox. ###
  echo "Building all Windows 11 Templates for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_18() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/desktop/11/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Windows 11 - Enterprise Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Windows 11 - Enterprise Template for Proxmox. ###
  echo "Building a Windows 11 - Enterprise Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      --only proxmox-iso.windows-desktop-ent \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_19() {
  INPUT_PATH="$SCRIPT_PATH"/builds/windows/desktop/11/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Windows 11 - Professional Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Windows 11 - Professional Templates for Proxmox. ###
  echo "Building a Windows 11 - Professional Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      --only proxmox-iso.windows-desktop-pro \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

press_enter() {
  cd "$SCRIPT_PATH"
  echo -n "Press Enter to continue."
  read -r
  clear
}

info() {
  echo "License: BSD-2"
  echo ""
  echo "For more information, review the project README."
  read -r
}

incorrect_selection() {
  echo "Invalid selection, please try again."
}

until [ "$selection" = "0" ]; do
  clear
  echo ""
  echo "    ____                __                  ____                                             "
  echo "   / __ \ ____ _ _____ / /__ ___   _____   / __ \ _____ ____   _  __ ____ ___   ____   _  __ "
  echo '  / /_/ // __ `// ___// //_// _ \ / ___/  / /_/ // ___// __ \ | |/_// __ `__ \ / __ \ | |/_/ '
  echo " / ____// /_/ // /__ / ,<  /  __// /     / ____// /   / /_/ /_>  < / / / / / // /_/ /_>  <   "
  echo '/_/     \__,_/ \___//_/|_| \___//_/     /_/    /_/    \____//_/|_|/_/ /_/ /_/ \____//_/|_|   '
  echo ""
  echo -n "  Select a HashiCorp Packer build for your hypervisor:"
  echo ""
  echo ""
  echo "      Linux Distribution:"
  echo ""
  echo "       1  -  AlmaLinux 10"
  echo "       2  -  AlmaLinux 9"
  echo "       3  -  AlmaLinux 8"
  echo "       4  -  CentOS 10 Stream"
  echo "       5  -  CentOS 9 Stream"
  echo "       6  -  Debian 12"
  echo "       7  -  Debian 11"
  echo "       8  -  OpenSUSE Leap 15.6"
  echo "       9  -  OpenSUSE Leap 15.5"
  echo "       10 -  Oracle Linux 9"
  echo "       11 -  Oracle Linux 8"
  echo "       12 -  Rocky Linux 9"
  echo "       13 -  Rocky Linux 8"
  echo "       14 -  Ubuntu Server 24.04 LTS"
  echo "       15 -  Ubuntu Server 22.04 LTS"
  echo "       16 -  Ubuntu Server 20.04 LTS"
  echo "       17 -  Windows 11 - All"
  echo "       18 -  Windows 11 - Enterprise Only"
  echo "       19 -  Windows 11 - Professional Only"
  echo ""
  echo "      Other:"
  echo ""
  echo "        I   -  Information"
  echo "        Q   -  Quit"
  echo ""
  read -r selection
  echo ""
  case $selection in
    1 ) clear ; menu_option_1  ; press_enter ;;
    2 ) clear ; menu_option_2  ; press_enter ;;
    3 ) clear ; menu_option_3  ; press_enter ;;
    4 ) clear ; menu_option_4  ; press_enter ;;
    5 ) clear ; menu_option_5  ; press_enter ;;
    6 ) clear ; menu_option_6  ; press_enter ;;
    7 ) clear ; menu_option_7  ; press_enter ;;
    8 ) clear ; menu_option_8  ; press_enter ;;
    9 ) clear ; menu_option_9  ; press_enter ;;
    10) clear ; menu_option_10 ; press_enter ;;
    11) clear ; menu_option_11 ; press_enter ;;
    12) clear ; menu_option_12 ; press_enter ;;
    13) clear ; menu_option_13 ; press_enter ;;
    14) clear ; menu_option_14 ; press_enter ;;
    15) clear ; menu_option_15 ; press_enter ;;
    16) clear ; menu_option_16 ; press_enter ;;
    17) clear ; menu_option_17 ; press_enter ;;
    18) clear ; menu_option_18 ; press_enter ;;
    19) clear ; menu_option_19 ; press_enter ;;
    [Ii] ) clear ; info ; press_enter ;;
    [Qq] ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done
