locals {

  # Determine if LVM is enabled
  lvm_enabled = length(var.vm_logical_volumes) > 0

  # Optional: Normalize fat32 -> vfat for Debian
  normalized_disk_layout = [
    for p in var.vm_disk_layout : merge(p, {
      filesystem = merge(p.filesystem, {
        fstype = p.filesystem.fstype == "fat32" ? "vfat" : p.filesystem.fstype
      })
    })
  ]

  normalized_logical_volumes = [
    for lv in var.vm_logical_volumes : merge(lv, {
      filesystem = merge(lv.filesystem, {
        fstype = lv.filesystem.fstype == "fat32" ? "vfat" : lv.filesystem.fstype
      })
    })
  ]

  storage_plan = {
    device          = var.vm_disk_device
    firmware        = var.vm_firmware
    partitions      = local.normalized_disk_layout
    logical_volumes = local.normalized_logical_volumes
    lvm_enabled     = local.lvm_enabled
    volume_groups   = distinct([
      for lv in local.normalized_logical_volumes : lv.vg_name
    ])
  }

  rendered_storage = templatefile(
    "${abspath(path.root)}/data/storage.pkrtpl.hcl", {
      plan = local.storage_plan
    }
  )
}
