/*
  DESCRIPTION:
  Rocky Linux 10 Anaconda Kickstart Storage Translator.

  PURPOSE:
  Generates declarative Kickstart commands ('part', 'volgroup', 'logvol').
  Ensures consistent disk assignment via '--ondisk' and handles
  RHEL-specific LVM spanning syntax.
*/


locals {

  # --------------------------------------------------
  # Generate Kickstart partition lines
  # --------------------------------------------------
  partition_lines = compact([
    for p in local.storage_data.partitions :
      p.role == "bios_grub" ? "part biosboot --fstype=bios_grub --size=${p.size} --ondisk=${p.disk_device}" :
      p.role == "efi" ? "part ${p.filesystem.mount} --fstype=vfat --size=${p.size} --ondisk=${p.disk_device}${p.filesystem.label != "" ? " --label=${p.filesystem.label}" : ""}" :
      p.role == "filesystem" ? "part ${p.filesystem.mount} --fstype=${p.filesystem.fstype} ${p.size == -1 ? "--size=100 --grow" : "--size=${p.size}"} --ondisk=${p.disk_device}${p.filesystem.label != "" ? " --label=${p.filesystem.label}" : ""}${p.filesystem.options != "" ? " --fsoptions=\"${p.filesystem.options}\"" : ""}" :
      p.role == "swap" ? "part swap --fstype=swap --size=${p.size} --ondisk=${p.disk_device}" :
      p.role == "pv" ? "part ${p.pv_name} ${p.size == -1 ? "--size=100 --grow" : "--size=${p.size}"} --ondisk=${p.disk_device}" :
      null
  ])

  # --------------------------------------------------
  # Generate Kickstart VG lines
  # --------------------------------------------------
  volgroup_lines = [
    for vg in var.vm_storage.volume_groups :
    length(local.storage_data.pv_per_vg[vg.name]) > 0 ?
      "volgroup ${vg.name} ${join(" ", local.storage_data.pv_per_vg[vg.name])}" : null
  ]

  # --------------------------------------------------
  # Generate Kickstart logical volume lines
  # --------------------------------------------------
  logvol_lines = [
    for lv in local.storage_data.logical_vols :
    format(
      "logvol %s --name=%s --vgname=%s --fstype=%s%s%s%s",
      lv.filesystem.fstype == "swap" ? "swap" : lv.filesystem.mount,
      lv.name,
      lv.vg_name,
      lv.filesystem.fstype,
      lv.filesystem.label != "" ? format(" --label=%s", lv.filesystem.label) : "",
      lv.filesystem.options != "" ? format(" --fsoptions=\"%s\"", lv.filesystem.options) : "",
      lv.size == -1 ? " --grow --size=100" : format(" --size=%d", lv.size)
    )
  ]

  # --------------------------------------------------
  # Build final Kickstart storage plan
  # --------------------------------------------------
storage_plan = {
  disks           = local.storage_data.disks
  partition_lines = local.partition_lines
  volgroup_lines  = local.volgroup_lines
  logvol_lines    = local.logvol_lines
  lvm_enabled     = local.storage_data.lvm_enabled
}

  # --------------------------------------------------
  # Render Kickstart template
  # --------------------------------------------------
  rendered_storage = templatefile(
    "${abspath(path.root)}/data/storage.pkrtpl.hcl",
    {
      plan = local.storage_plan
    }
  )

}
