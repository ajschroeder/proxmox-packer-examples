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

# Menu registry
# Format: key="Label|RelativeInputPath"
declare -A MENU_ITEMS=(
  [1]="AlmaLinux 10|linux/almalinux/10"
  [2]="AlmaLinux 9|linux/almalinux/9"
  [3]="AlmaLinux 8|linux/almalinux/8"
  [4]="CentOS 10 Stream|linux/centos/10-stream"
  [5]="CentOS 9 Stream|linux/centos/9-stream"
  [6]="Debian 12 (Bookworm)|linux/debian/12"
  [7]="Debian 12 (Bullseye)|linux/debian/11"
  [8]="openSUSE Leap 15.6|linux/opensuse/leap-15-6"
  [9]="openSUSE Leap 15.5|linux/opensuse/leap-15-5"
  [10]="Oracle Linux 9|linux/oracle/9"
  [11]="Oracle Linux 8|linux/oracle/8"
  [12]="Rocky Linux 10|linux/rocky/10"
  [13]="Rocky Linux 9|linux/rocky/9"
  [14]="Rocky Linux 8|linux/rocky/8"
  [15]="Ubuntu Server 25.04|linux/ubuntu/25-04"
  [16]="Ubuntu Server 24.04 LTS|linux/ubuntu/24-04-lts"
  [17]="Ubuntu Server 22.04|linux/ubuntu/22-04-lts"
  [18]="Ubuntu Server 20.04|linux/ubuntu/20-04-lts"
  [19]="Windows 11 - All|windows/desktop/11|"
  [20]="Windows 11 - Enterprise|windows/desktop/11|--only proxmox-iso.windows-desktop-ent"
  [21]="Windows 11 - Professional|windows/desktop/11|--only proxmox-iso.windows-desktop-pro"
  [I]="Information|info"
  [Q]="Quit|quit_program"
)

build_template() {
  local label="$1"
  local relative_path="$2"
  local extra_args="$3"

  INPUT_PATH="$SCRIPT_PATH/builds/$relative_path"
  BUILD_PATH="${relative_path}"
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  # List of required var files
  local var_files=(
    "$CONFIG_PATH/ansible.pkrvars.hcl"
    "$CONFIG_PATH/build.pkrvars.hcl"
    "$CONFIG_PATH/common.pkrvars.hcl"
    "$CONFIG_PATH/linux-storage.pkrvars.hcl"
    "$CONFIG_PATH/network.pkrvars.hcl"
    "$CONFIG_PATH/proxmox.pkrvars.hcl"
    "$CONFIG_PATH/$BUILD_VARS"
  )

  # Validate all var files exist
  local missing_files=()
  for file in "${var_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      missing_files+=("$file")
    fi
  done

  if [[ ${#missing_files[@]} -ne 0 ]]; then
    echo "Error: The following required .pkrvars.hcl files are missing:"
    for f in "${missing_files[@]}"; do
      echo "  - $f"
    done
    echo "Aborting build."
    return 1
  fi

  # Confirmation prompt
  echo -e "\nCONFIRM: Build a $label Template for Proxmox?"
  read -rp "Continue? (y/n) " REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    return
  fi

  echo "Building a $label Template for Proxmox..."
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  echo "Starting the build..."
  packer build -force -on-error=ask $debug_option $extra_args \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  echo "Done."
}

dispatch_selection() {
  entry="${MENU_ITEMS[$selection]}"
  if [[ -z "$entry" ]]; then
    echo "Invalid selection."
    return
  fi

  IFS='|' read -r label path_or_function extra_args <<< "$entry"

  # Decide if it’s a build or a function
  if [[ -d "$SCRIPT_PATH/builds/$path_or_function" ]]; then
    build_template "$label" "$path_or_function" "$extra_args"
  else
    $path_or_function
  fi
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

quit_program() {
  echo "Exiting..."
  exit 0
}

read_selection() {
  read -rp "Selection: " input
  echo "${input^^}"  # always uppercase
}

display_menu() {
  clear
  echo ""
  echo "    ____                __                  ____                                             "
  echo "   / __ \ ____ _ _____ / /__ ___   _____   / __ \ _____ ____   _  __ ____ ___   ____   _  __ "
# Don't want to expand this non-expression, it's just ANSI art
# shellcheck disable=SC2016
  echo '  / /_/ // __ `// ___// //_// _ \ / ___/  / /_/ // ___// __ \ | |/_// __ `__ \ / __ \ | |/_/ '
  echo " / ____// /_/ // /__ / ,<  /  __// /     / ____// /   / /_/ /_>  < / / / / / // /_/ /_>  <   "
  echo '/_/     \__,_/ \___//_/|_| \___//_/     /_/    /_/    \____//_/|_|/_/ /_/ /_/ \____//_/|_|   '
  echo ""
  echo -n "  Select a HashiCorp Packer build for your hypervisor:"
  echo ""
  echo ""

  for key in $(printf "%s\n" "${!MENU_ITEMS[@]}" | sort -n 2>/dev/null); do
    IFS='|' read -r label _ <<< "${MENU_ITEMS[$key]}"
    printf "  %2s - %s\n" "$key" "$label"
  done
  echo ""
  selection=$(read_selection)
}

while true; do
  display_menu
  dispatch_selection
  echo ""
  read -rp "Press enter to continue..."
done
