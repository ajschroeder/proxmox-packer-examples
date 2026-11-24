/*
  DESCRIPTION:
  openSUSE Leap 16.1 Agama Storage Translator.

  PURPOSE:
  Converts the unified storage_data object into a valid Agama
  JSON `storage` block.
*/

locals {
  agama_drives = [
    for disk in local.storage_data.disks : {
      search     = "/dev/${disk.device_name}"
      alias      = disk.device_name
      ptableType = "gpt"
      partitions = concat(
        [
          {
            search = "*"
            delete = true
          }
        ],
        [
          for p in local.storage_data.partitions : merge(
            {
              id = (
                p.role == "efi" ? "esp" :
                p.role == "bios_grub" ? "bios_boot" :
                p.role == "pv" ? "lvm" :
                p.filesystem.fstype == "swap" ? "swap" : "linux"
              )
              size = p.size == -1 ? ["1 MiB"] : ["${p.size} MiB", "${p.size} MiB"]
            },
            p.role == "pv" ? { alias = p.pv_name } : {},
            p.role != "pv" && p.role != "bios_grub" ? {
              filesystem = merge(
                {
                  type = (
                    p.filesystem.fstype == "fat32" ? "vfat" :
                    p.filesystem.fstype == "swap" ? "swap" :
                    p.filesystem.fstype
                  )
                  path    = p.filesystem.fstype == "swap" ? "swap" : p.filesystem.mount
                  mountBy = "uuid"
                },
                p.filesystem.label != "" ? { label = p.filesystem.label } : {},
                p.filesystem.options != "" ? { mountOptions = [for o in split(",", p.filesystem.options) : trimspace(o) if trimspace(o) != ""] } : {}
              )
            } : {}
          )
          if p.disk_device == disk.device_name
        ]
      )
    }
  ]

  agama_volume_groups = [
    for vg in var.vm_storage.volume_groups : {
      name            = vg.name
      physicalVolumes = local.storage_data.pv_per_vg[vg.name]
      logicalVolumes = [
        for lv in local.storage_data.logical_vols : {
          name = lv.name
          size = lv.size == -1 ? ["1 MiB"] : ["${lv.size} MiB", "${lv.size} MiB"]
          filesystem = merge(
            {
              type    = lv.filesystem.fstype == "swap" ? "swap" : lv.filesystem.fstype
              path    = lv.filesystem.fstype == "swap" ? "swap" : lv.filesystem.mount
              mountBy = "device"
            },
            lv.filesystem.label != "" ? { label = lv.filesystem.label } : {},
            lv.filesystem.options != "" ? { mountOptions = [for o in split(",", lv.filesystem.options) : trimspace(o) if trimspace(o) != ""] } : {}
          )
        }
        if lv.vg_name == vg.name
      ]
    }
  ]

  agama_storage = merge(
    {
      boot = {
        configure = false
      }
      drives = local.agama_drives
    },
    length(local.agama_volume_groups) > 0 ? { volumeGroups = local.agama_volume_groups } : {}
  )

  rendered_storage = jsonencode(local.agama_storage)
}
