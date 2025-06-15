#!/usr/bin/env bash
set -e

# Load common functions
source common.sh

# === Colors ===
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m"

# === Paths ===
SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")
CONFIG_PATH=$(realpath "${1:-${SCRIPT_PATH}/config}")

INPUT_PATHS=(
  "$SCRIPT_PATH/builds/linux/almalinux/10/"
  "$SCRIPT_PATH/builds/linux/almalinux/9/"
  "$SCRIPT_PATH/builds/linux/almalinux/8/"
  "$SCRIPT_PATH/builds/linux/centos/10-stream/"
  "$SCRIPT_PATH/builds/linux/centos/9-stream/"
  "$SCRIPT_PATH/builds/linux/debian/12/"
  "$SCRIPT_PATH/builds/linux/debian/11/"
  "$SCRIPT_PATH/builds/linux/opensuse/leap-15-6/"
  "$SCRIPT_PATH/builds/linux/opensuse/leap-15-5/"
  "$SCRIPT_PATH/builds/linux/oracle/9/"
  "$SCRIPT_PATH/builds/linux/oracle/8/"
  "$SCRIPT_PATH/builds/linux/rocky/9/"
  "$SCRIPT_PATH/builds/linux/rocky/8/"
  "$SCRIPT_PATH/builds/linux/ubuntu/24-04-lts/"
  "$SCRIPT_PATH/builds/linux/ubuntu/22-04-lts/"
  "$SCRIPT_PATH/builds/linux/ubuntu/20-04-lts/"
  "$SCRIPT_PATH/builds/windows/desktop/11/"
)

# === Result storage ===
declare -a summary=()

# === Validation Function ===
validate_packer() {
  local input_path="$1"
  local current_build_path current_build_vars os version

  version=$(basename "$input_path")
  os=$(basename "$(dirname "$input_path")")

  echo -e "${BLUE}▶ Validating: ${YELLOW}${os^^} ${version}${NC}"

  if echo "$input_path" | grep -qi "windows"; then
    current_build_path=${input_path#"${SCRIPT_PATH}/builds/"}
    current_build_vars="$(echo "${current_build_path%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"
    VAR_FILES=(
      "$CONFIG_PATH/ansible.pkrvars.hcl"
      "$CONFIG_PATH/build.pkrvars.hcl"
      "$CONFIG_PATH/common.pkrvars.hcl"
      "$CONFIG_PATH/network.pkrvars.hcl"
      "$CONFIG_PATH/proxmox.pkrvars.hcl"
      "$CONFIG_PATH/proxy.pkrvars.hcl"
      "$CONFIG_PATH/$current_build_vars"
    )
  else
    current_build_path=${input_path#"${SCRIPT_PATH}/builds/"}
    current_build_vars="$(echo "${current_build_path%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"
    VAR_FILES=(
      "$CONFIG_PATH/ansible.pkrvars.hcl"
      "$CONFIG_PATH/build.pkrvars.hcl"
      "$CONFIG_PATH/common.pkrvars.hcl"
      "$CONFIG_PATH/linux-storage.pkrvars.hcl"
      "$CONFIG_PATH/network.pkrvars.hcl"
      "$CONFIG_PATH/proxmox.pkrvars.hcl"
      "$CONFIG_PATH/proxy.pkrvars.hcl"
      "$CONFIG_PATH/$current_build_vars"
    )
  fi

if packer_output=$(packer validate "${VAR_FILES[@]/#/--var-file=}" "$input_path" 2>&1); then
  echo -e "  ${GREEN}✔ PASS${NC}"
  summary+=("${os}/${version} : PASS")
else
  echo -e "  ${RED}✘ FAIL${NC}"
  echo "$packer_output"
  summary+=("${os}/${version} : FAIL")
fi

  echo -e "${NC}----------------------------------------"
}

# === Main Execution ===
echo -e "${BLUE}==> Starting Packer validations...${NC}"
for path in "${INPUT_PATHS[@]}"; do
  validate_packer "$path"
done

# === Summary Output ===
echo -e "\n${BLUE}==> Validation Summary:${NC}"
for entry in "${summary[@]}"; do
  if [[ "$entry" == *FAIL ]]; then
    echo -e "${RED}$entry${NC}"
  else
    echo -e "${GREEN}$entry${NC}"
  fi
done

