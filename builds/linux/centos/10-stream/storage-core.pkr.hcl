/*
  DESCRIPTION:
  CentOS Stream 10 Unified Storage Core Logic for Packer Proxmox Automation.

  PURPOSE:
  Handles distro-agnostic storage calculations, partition sizing,
  and LVM grouping. This file processes raw 'vm_storage' input into
  a flattened data structure used by specific OS installers.
*/


locals {
  # 1. Hardware Mapping (Proxmox Builder)
  # This is what your dynamic "disks" block consumes.
  proxmox_disks = [
    for disk in local.indexed_disks : {
      type         = lookup(disk, "type", var.vm_disk_type)
      disk_size    = disk.size
      storage_pool = disk.storage_pool
      format       = lookup(disk, "format", var.vm_disk_format)
    }
  ]

  # 2. Device Naming (OS Level)
  indexed_disks = [
    for idx, d in var.vm_storage.disks : merge(d, {
      device_name = format("vd%s", lower(substr("abcdefghijklmnopqrstuvwxyz", idx, 1)))
    })
  ]

  # 3. Flattened Partitions for Indexing
  all_parts_context = flatten([
    for disk in local.indexed_disks : [
      for p_idx, p in disk.partitions : merge(p, {
        disk_device = disk.device_name
        part_index  = p_idx
        uid         = "${disk.device_name}-${p_idx}"
      })
    ]
  ])

  # 4. Sequential PV Naming (Legacy Kickstart Compatibility)
  pv_only_list = [for p in local.all_parts_context : p if p.role == "pv"]
  pv_mapping   = { for idx, p in local.pv_only_list : p.uid => format("pv.%02d", idx + 1) }

  # 5. Normalized Partitions (Storage API Contract)
  normalized_partitions = [
    for p in local.all_parts_context : merge(p, {
      pv_name = lookup(local.pv_mapping, p.uid, "")
      filesystem = merge(
        { fstype = "", mount = "", label = "", options = "" },
        p.filesystem != null ? p.filesystem : {}
      )
    })
  ]

  # 6. Normalized Logical Volumes
  normalized_logical_volumes = flatten([
    for vg in var.vm_storage.volume_groups : [
      for lv in vg.logical_volumes : merge(lv, {
        vg_name = vg.name
        filesystem = merge(
          { fstype = "", mount = "", label = "", options = "" },
          lv.filesystem != null ? lv.filesystem : {}
        )
      })
    ]
  ])

  # 7. Final Storage API Object
  storage_data = {
    disks         = local.indexed_disks
    partitions    = local.normalized_partitions
    logical_vols  = local.normalized_logical_volumes
    pv_per_vg     = {
      for vg in var.vm_storage.volume_groups :
      vg.name => [for p in local.normalized_partitions : p.pv_name if p.role == "pv" && p.vg == vg.name]
    }
    lvm_enabled   = length(local.normalized_logical_volumes) > 0
    proxmox_disks = local.proxmox_disks
  }

  # 8. ADR-0002 Firmware & Boot Partition Guard
  # Logic: We create a lookup map of valid "Firmware + Boot Role" combinations.
  # If the user provides a combination not in this map, Packer will error out immediately during the refresh/inspect phase.
  # This is the only storage validation check not present inside of variables-storage.pkr.hcl due to variable scoping.

  _has_efi       = length([for p in local.normalized_partitions : p if p.role == "efi"]) > 0
  _has_bios_grub = length([for p in local.normalized_partitions : p if p.role == "bios_grub"]) > 0

  # Logic Gate: Is the current configuration valid?
  # UEFI must have EFI and NO BIOS_GRUB.
  # BIOS must have BIOS_GRUB and NO EFI.
  _is_uefi_valid = var.vm_firmware == "ovmf"    && local._has_efi       && !local._has_bios_grub
  _is_bios_valid = var.vm_firmware == "seabios" && local._has_bios_grub && !local._has_efi

  _is_storage_valid = local._is_uefi_valid || local._is_bios_valid

  # Use format() to guarantee a clean string without hidden type-casting artifacts
  _current_state = format("%s:%t:%t", var.vm_firmware, local._has_efi, local._has_bios_grub)

  # --- THE GUARD ---
  # This provides a deterministic "Fail Fast" mechanism.
  # If NOT valid, we trigger the error. If valid, we return a benign string.
  firmware_validation_check = local._is_storage_valid ? "valid" : file("ERROR_ADR0002: Firmware [${var.vm_firmware}] mismatch. UEFI needs 'efi' role; BIOS needs 'bios_grub' role. You cannot cross the streams!")


}
