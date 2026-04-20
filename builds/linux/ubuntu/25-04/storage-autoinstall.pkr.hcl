/*
  DESCRIPTION:
  Ubuntu Server 25.04 Subiquity Autoinstall Storage Translator.

  PURPOSE:
  Maps the unified storage plan to the 'storage: config:' YAML schema.
  Handles Subiquity-specific requirements like 'id' referencing and
  'lvm_volgroup' device arrays.
*/

locals {

  # --------------------------------------------------
  # Map PV names to IDs for LVM
  # --------------------------------------------------
  pv_name_to_id = {
    for idx, p in local.storage_data.partitions :
    p.pv_name => "pv-${idx}"
    if p.role == "pv"
  }

  # --------------------------------------------------
  # Generate Autoinstall disk definitions
  # --------------------------------------------------
  disk_lines = [
    for d in local.storage_data.disks : <<-EOT
- type: disk
  id: ${d.device_name}
  ptable: gpt
  wipe: superblock-recursive
  grub_device: false
EOT
  ]

  # --------------------------------------------------
  # Generate Autoinstall partition definitions
  # --------------------------------------------------
  partition_lines = flatten([
    for d_idx, d in var.vm_storage.disks : [
      for p_idx, p in d.partitions : <<-EOT
- type: partition
  id: part-${d_idx}-${p_idx}
  device: ${d.device}
  size: ${p.size == -1 ? "-1" : "${p.size}M"}
  wipe: superblock
  preserve: false
  grub_device: ${p.role == "efi" ? "true" : "false"}
  ${p.role == "efi" ? "flag: boot" : ""}
%{ if p.role != "pv" ~}
- type: format
  id: fmt-part-${d_idx}-${p_idx}
  volume: part-${d_idx}-${p_idx}
  fstype: ${p.role == "swap" ? "swap" : (p.role == "efi" ? "fat32" : (p.filesystem.fstype != "" ? p.filesystem.fstype : "ext4"))}
- type: mount
  id: mount-part-${d_idx}-${p_idx}
  device: fmt-part-${d_idx}-${p_idx}
  path: ${p.role == "swap" ? "none" : p.filesystem.mount}
%{ endif ~}
EOT
    ]
  ])

  # --------------------------------------------------
  # Generate Autoinstall LVM volume groups
  # --------------------------------------------------
  volgroup_lines = [
    for vg in var.vm_storage.volume_groups : <<-EOT
- type: lvm_volgroup
  id: vg-${vg.name}
  name: ${vg.name}
  devices:
    - ${join("\n    - ", flatten([
        for d_idx, d in var.vm_storage.disks : [
          for p_idx, p in d.partitions : "part-${d_idx}-${p_idx}" if p.vg == vg.name
        ]
      ]))}
EOT
  ]

  # --------------------------------------------------
  # Generate Autoinstall logical volumes
  # --------------------------------------------------
  logvol_lines = [
    for idx, lv in local.storage_data.logical_vols :
      <<-EOT
- type: lvm_partition
  id: lv-${idx}
  name: ${lv.name}
  volgroup: vg-${lv.vg_name}
  size: ${lv.size == -1 ? "-1" : "${lv.size}M"}
- type: format
  id: fmt-lv-${idx}
  volume: lv-${idx}
  fstype: ${lv.name == "swap" || lv.filesystem.fstype == "swap" ? "swap" : "ext4"}
- type: mount
  id: mount-lv-${idx}
  device: fmt-lv-${idx}
  path: ${lv.name == "swap" || lv.filesystem.fstype == "swap" ? "none" : lv.filesystem.mount}
EOT
  ]

  # --------------------------------------------------
  # Build final Autoinstall storage plan, using compact to make sure each array is null-free
  # --------------------------------------------------
  storage_plan = {
    disk_lines      = [for s in compact(local.disk_lines) : trimspace(s)]
    partition_lines = [for s in compact(flatten(local.partition_lines)) : trimspace(s)]
    volgroup_lines  = [for s in compact(flatten(local.volgroup_lines)) : trimspace(s)]
    logvol_lines    = [for s in compact(flatten(local.logvol_lines)) : trimspace(s)]
    lvm_enabled     = local.storage_data.lvm_enabled
  }

  # --------------------------------------------------
  # Render Autoinstall template
  # --------------------------------------------------
  rendered_storage = templatefile(
    "${abspath(path.root)}/data/storage.pkrtpl.hcl",
    {
      plan = local.storage_plan
    }
  )

}
