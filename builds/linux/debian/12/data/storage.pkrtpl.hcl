# --- Global Storage Setup ---
# Dynamically derived from the Storage API (supports single or multi-disk)
d-i partman-auto/disk string ${auto_disks}
d-i partman-auto/method string ${ lvm_enabled ? "lvm" : "regular" }
d-i partman-auto/choose_recipe select universal_api

# Force GPT Labeling for all modern templates
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt

%{~ if lvm_enabled ~}
# LVM specific cleaning and initialization
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

# The first VG in the list is treated as the primary system VG for guided components
d-i partman-auto-lvm/new_vg_name string ${volume_groups[0]}
%{~ endif ~}

# --- Bootloader Configuration ---
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean false
d-i grub-installer/bootdev string ${boot_device}

# --- Firmware Specific Logic (ADR-0002) ---
%{~ if firmware == "ovmf" ~}
# UEFI (OVMF) Requirements
d-i grub-installer/force-efi-extra-removable boolean true
d-i partman-efi/non_efi_system boolean true
%{~ endif ~}

# --- Expert Recipe ---
# The recipe_string is pre-formatted with backslashes and indentation in HCL
d-i partman-auto/expert_recipe string universal_api :: \
${recipe_string}

# --- Final Partitioning Guards ---
# These ensure the installer doesn't hang waiting for "Are you sure?" prompts
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Suppress manual intervention for complex multi-disk/LVM layouts
d-i partman-basicmethods/method_only boolean false
d-i partman-auto/purge_lvm_from_device boolean true
