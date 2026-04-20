/*
  DESCRIPTION:
  openSUSE Leap 15.6 AutoYaST Storage Translator.

  PURPOSE:
  Converts the unified storage_data object into a valid AutoYaST
  XML <partitioning> block.
*/

locals {
  # We pass the flattened storage_data directly into the template
  rendered_storage = templatefile("${path.root}/data/storage.pkrtpl.hcl", {
    disks          = local.storage_data.disks
    partitions     = local.storage_data.partitions
    logical_vols   = local.storage_data.logical_vols
    volume_groups  = var.vm_storage.volume_groups
  })
}
