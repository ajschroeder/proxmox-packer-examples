/*
  DESCRIPTION:
  Debian 12 Partman Preseed Storage Translator.

  PURPOSE:
  Converts the unified storage plan into the 'd-i partman/expert_recipe'
  format. Manages EFI/BIOS partition flags and complex LVM recipe strings
  required by the Debian classic installer.
*/


locals {
  # --- 1. Device Mapping ---
  # Generates the string for d-i partman-auto/disk (e.g., "/dev/vda /dev/vdb")
  all_device_paths = [for d in local.storage_data.disks : "/dev/${d.device_name}"]

  # --- 2. Boot Disk Identification ---
  # Ensures the bootloader is installed to the disk containing EFI or BIOS_GRUB
  boot_disks = distinct(flatten([
    for d in local.storage_data.disks : [
      for p in d.partitions : d.device_name
      if p.role == "efi" || p.role == "bios_grub"
    ]
  ]))
  boot_disk_name = length(local.boot_disks) > 0 ? local.boot_disks[0] : local.storage_data.disks[0].device_name

  # --- 3. Physical Partition Generation (Spec-Compliant) ---
  debian_partition_strings = [
    for p in local.storage_data.partitions :
    join(" ", compact([
      # Size Logic: PVs use high limits to force disk consumption; others use fixed 1:1:1
      p.role == "pv" ? "100 1000 1000000000" : (p.size == -1 ? "100 1000 1000000" : "${p.size} ${p.size} ${p.size}"),

      # The "Type" string (4th column)
      p.role == "pv" ? "$default_filesystem" : (p.role == "efi" ? "fat32" : p.filesystem.fstype),

      # Specifiers
      p.role == "pv" ? "$defaultignore{ }" : "",
      "$primary{ }",
      p.filesystem.mount == "/boot" ? "$bootable{ }" : "",

      # Method Logic
      p.role == "efi" ? "method{ efi } format{ }" : (
        p.role == "pv" ? "method{ lvm } device{ /dev/${p.disk_device} } vg_name{ ${p.vg} }" : (
          # Raw partitions (e.g., /boot)
          join(" ", compact([
            "method{ ${p.filesystem.fstype == "swap" ? "swap" : "format"} } format{ }",
            p.filesystem.fstype != "swap" ? "use_filesystem{ } filesystem{ ${p.filesystem.fstype} }" : "",
            p.filesystem.mount != "" ? "mountpoint{ ${p.filesystem.mount} }" : ""
          ]))
        )
      ),
      "."
    ]))
  ]

  # --- 4. Logical Volume Generation (Spec-Compliant) ---
  # Sort to ensure -1 (Grow) volumes are last within their respective VGs
  _root_lvs   = [for lv in local.storage_data.logical_vols : lv if lv.size == -1]
  _fixed_lvs  = [for lv in local.storage_data.logical_vols : lv if lv.size != -1]
  _sorted_lvs = concat(local._fixed_lvs, local._root_lvs)

  debian_lv_strings = [
    for lv in local._sorted_lvs :
    join(" ", compact([
      # Size-Priority-Limit: -1 becomes the "fill rest" catch-all
      lv.size == -1 ? "100 1000 -1" : "${lv.size} ${lv.size} ${lv.size}",

      # Type string
      lv.filesystem.fstype == "swap" ? "linux-swap" : lv.filesystem.fstype,

      # Specifiers
      "$lvmok{ }",
      "in_vg{ ${lv.vg_name} }",
      "lv_name{ ${lv.name} }",

      # Method Logic
      lv.filesystem.fstype == "swap" ? "method{ swap } format{ }" : (
        join(" ", [
          "method{ format } format{ } use_filesystem{ }",
          "filesystem{ ${lv.filesystem.fstype} }",
          "mountpoint{ ${lv.filesystem.mount} }"
        ])
      ),
      "."
    ]))
  ]

  # --- 5. Assembly ---
  # We use compact() to remove any empty strings and trimspace() to kill hidden tabs/spaces.
  # The join uses a clean " \n" (One space then newline) with no trailing garbage.
  final_recipe = join(" \\\n", [for s in concat(local.debian_partition_strings, local.debian_lv_strings) : trimspace(s)])

  # --- 6. Render ---
  rendered_storage = templatefile(
    "${path.root}/data/storage.pkrtpl.hcl",
    {
      auto_disks    = join(" ", local.all_device_paths)
      recipe_string = local.final_recipe
      # Enable LVM if any VGs are defined in the source variable
      lvm_enabled   = length(var.vm_storage.volume_groups) > 0
      volume_groups = [for vg in var.vm_storage.volume_groups : vg.name]
      firmware      = var.vm_firmware
      boot_device   = "/dev/${local.boot_disk_name}"
    }
  )
}
