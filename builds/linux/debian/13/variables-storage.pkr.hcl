/*
    DESCRIPTION:
    Debian 13 storage variables used by the Packer Plugin for Proxmox (proxmox-iso).
*/

// VM Storage Settings

variable "vm_disk_device" {
  type        = string
  description = "The device for the virtual disk. (e.g. 'vda')"
}

variable "vm_disk_layout" {
  type = list(object({
    name    = string
    size    = number
    role    = string  # efi | bios_grub | pv | swap | filesystem
    vg_name = string  # "" if not a PV
    filesystem = object({
      fstype  = string
      label   = string
      mount   = string
      options = string
    })
  }))

  validation {
    condition = alltrue([
      for p in var.vm_disk_layout : contains(["efi","bios_grub","pv","swap","filesystem"], p.role)
    ])
    error_message = "Partition type must be 'partition' or 'pv'."
  }

  validation {
    condition = length([
      for p in var.vm_disk_layout : p.size if p.size == -1
    ]) <= 1
    error_message = "Only one physical partition may use size = -1."
  }

  validation {
    condition = alltrue([
      for p in var.vm_disk_layout : p.role == "pv" ? p.vg_name != "" : p.vg_name == ""
    ])
    error_message = "PV partitions must define vg_name; other partitions must leave vg_name empty."
  }
}

variable "vm_logical_volumes" {
  type = list(object({
    vg_name = string
    name    = string
    size    = number

    filesystem = object({
      fstype  = string
      label   = string
      mount   = string
      options = string
    })
  }))
  default = []

  validation {
    condition = alltrue([
      for lv in var.vm_logical_volumes : lv.vg_name != ""
    ])
    error_message = "All logical volumes must define vg_name."
  }

  validation {
    condition = length([
      for lv in var.vm_logical_volumes : lv.size if lv.size == -1
    ]) <= 1
    error_message = "Only one logical volume may use size = -1."
  }
}
