#!/usr/bin/env bash

set -e

source common.sh

SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")
CONFIG_PATH=$(realpath "${1:-${SCRIPT_PATH}/config}")

menu_option_1() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/centos/8-stream/
  echo -e "\nCONFIRM: Build a CentOS 8 Stream Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a CentOS 8 Stream Template for Proxmox. ###
  echo "Building a CentOS 8 Stream Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_2() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/centos/9-stream/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_3() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/debian/11/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_4() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/debian/12/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_5() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/20-04-lts/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_6() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/20-04-lts/
  echo -e "\nCONFIRM: Build a Ubuntu Server 20.04 LTS (cloud-init) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 20.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 20.04 LTS (cloud-init) Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var "vm_cloud_init_enable=true" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_7() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/22-04-lts/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_8() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/22-04-lts/
  echo -e "\nCONFIRM: Build a Ubuntu Server 22.04 LTS (cloud-init) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 22.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 22.04 LTS (cloud-init) Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var "vm_cloud_init_enable=true" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_9() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/24-04-lts/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_10() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/ubuntu/24-04-lts/
  echo -e "\nCONFIRM: Build a Ubuntu Server 24.04 LTS (cloud-init) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Ubuntu Server 24.04 LTS Template for Proxmox. ###
  echo "Building a Ubuntu Server 24.04 LTS (cloud-init) Template for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var "vm_cloud_init_enable=true" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_11() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/opensuse/leap-15-5/
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
  packer build -force \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
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
  echo "       1  -  CentOS 8 Stream"
  echo "       2  -  CentOS 9 Stream"
  echo "       3  -  Debian 11 (Bullseye)"
  echo "       4  -  Debian 12 (Bookworm)"
  echo "       5  -  Ubuntu Server 20.04 LTS"
  echo "       6  -  Ubuntu Server 20.04 LTS (cloud-init)"
  echo "       7  -  Ubuntu Server 22.04 LTS"
  echo "       8  -  Ubuntu Server 22.04 LTS (cloud-init)"
  echo "       9  -  Ubuntu Server 24.04 LTS"
  echo "       10 -  Ubuntu Server 24.04 LTS (cloud-init)"
  echo "       11 -  OpenSUSE Leap 15.5"
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
    [Ii] ) clear ; info ; press_enter ;;
    [Qq] ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done
