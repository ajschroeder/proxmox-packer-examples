#!/usr/bin/env bash
set -euo pipefail

source common.sh

# === Colors ===
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m"

# === Paths ===
SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")
BUILDS_PATH="${SCRIPT_PATH}/builds"

# === Defaults ===
CONFIG_PATH=""
BUILD_FILTER=""
OS_FILTER=""
VERSION_FILTER=""
JOBS=4
LIST_BUILDS=0

# === Usage ===
usage() {
cat <<EOF
Usage: $0 [options]

Options:
  -c, --config <path>     Config directory
  -b, --build <name>      Specific build (ex: ubuntu/24-04-lts)
  -o, --os <name>         Filter by OS
  -v, --version <ver>     Filter by version
  -j, --jobs <num>        Parallel validations (default: 4)
  -l, --list              List available builds
  -h, --help              Show help
EOF
exit 1
}

# === Convert long options to short ===
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)   ARGS+=("-c" "$2"); shift 2 ;;
    --build)    ARGS+=("-b" "$2"); shift 2 ;;
    --os)       ARGS+=("-o" "$2"); shift 2 ;;
    --version)  ARGS+=("-v" "$2"); shift 2 ;;
    --jobs)     ARGS+=("-j" "$2"); shift 2 ;;
    --list)     ARGS+=("-l"); shift ;;
    --help)     ARGS+=("-h"); shift ;;
    *)          ARGS+=("$1"); shift ;;
  esac
done

set -- "${ARGS[@]}"

# === Parse CLI ===
while getopts ":c:b:o:v:j:lh" opt; do
  case ${opt} in
    c) CONFIG_PATH="$OPTARG" ;;
    b) BUILD_FILTER="$OPTARG" ;;
    o) OS_FILTER="$OPTARG" ;;
    v) VERSION_FILTER="$OPTARG" ;;
    j) JOBS="$OPTARG" ;;
    l) LIST_BUILDS=1 ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG"; usage ;;
    :) echo "Option -$OPTARG requires argument."; usage ;;
  esac
done

CONFIG_PATH=$(realpath "${CONFIG_PATH:-${SCRIPT_PATH}/config}")

TMP_RESULTS=$(mktemp)
trap 'rm -f "$TMP_RESULTS"' EXIT

# === Discover builds ===
mapfile -t INPUT_PATHS < <(
  find "$BUILDS_PATH" -mindepth 3 -maxdepth 3 -type d | sort
)

# === List builds ===
list_builds() {

  echo -e "${BLUE}Available builds:${NC}"

  for path in "${INPUT_PATHS[@]}"; do
    build="${path#"${BUILDS_PATH}/"}"

    # Use awk to extract platform, OS, version
    os=$(echo "$build" | awk -F'/' '{if ($1=="windows") print "windows"; else print $2}')
    version=$(echo "$build" | awk -F'/' '{if ($1=="windows") print $3; else print $3}')

    echo "  ${os}/${version}"
  done

}

if [[ "$LIST_BUILDS" -eq 1 ]]; then
  list_builds
  exit 0
fi

# === Validation function ===
validate_packer() {

  local input_path="$1"

  local version os platform
  local current_build_path current_build_vars
  local packer_output

  version=$(basename "$input_path")
  os=$(basename "$(dirname "$input_path")")
  platform=$(basename "$(dirname "$(dirname "$input_path")")")

  echo -e "${BLUE}▶ Validating: ${YELLOW}${os^^} ${version}${NC}"

  current_build_path=${input_path#"${SCRIPT_PATH}/builds/"}
  current_build_vars="$(echo "${current_build_path%/}" | tr '/' '-').pkrvars.hcl"

  if [[ "$platform" == "windows" ]]; then
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
    echo "${os}/${version} : PASS" >> "$TMP_RESULTS"
  else
    echo -e "  ${RED}✘ FAIL${NC}"
    echo "$packer_output"
    echo "${os}/${version} : FAIL" >> "$TMP_RESULTS"
  fi

  echo "----------------------------------------"
}

export -f validate_packer
export SCRIPT_PATH CONFIG_PATH TMP_RESULTS
export GREEN YELLOW RED BLUE NC

# === Apply filters ===
FILTERED_PATHS=()

for path in "${INPUT_PATHS[@]}"; do

  os=$(basename "$(dirname "$path")")
  version=$(basename "$path")

  if [[ -n "$BUILD_FILTER" ]] && [[ "$path" != *"$BUILD_FILTER"* ]]; then
    continue
  fi

  if [[ -n "$OS_FILTER" ]] && [[ "$os" != "$OS_FILTER" ]]; then
    continue
  fi

  if [[ -n "$VERSION_FILTER" ]] && [[ "$version" != "$VERSION_FILTER" ]]; then
    continue
  fi

  FILTERED_PATHS+=("$path")

done

if [[ ${#FILTERED_PATHS[@]} -eq 0 ]]; then
  echo -e "${RED}No builds matched your filters.${NC}"
  echo
  list_builds
  exit 1
fi

echo -e "${BLUE}==> Starting Packer validations (${#FILTERED_PATHS[@]} builds, ${JOBS} parallel jobs)...${NC}"

printf "%s\n" "${FILTERED_PATHS[@]}" \
  | xargs -I{} -P "$JOBS" bash -c 'validate_packer "$@"' _ {}

echo
echo -e "${BLUE}==> Validation Summary:${NC}"

while read -r entry; do
  if [[ "$entry" == *FAIL ]]; then
    echo -e "${RED}$entry${NC}"
  else
    echo -e "${GREEN}$entry${NC}"
  fi
done < "$TMP_RESULTS"
