/*
  DESCRIPTION:
  openSUSE Leap 15.5 unified storage variables for Packer Plugin for Proxmox (proxmox-iso)
*/

variable "vm_disk_controller_type" {
  type        = string
  description = "The SCSI controller model to emulate. (e.g. 'virtio-scsi-pci')"
}

variable "vm_disk_type" {
  type        = string
  description = "The type of disk to emulate. (e.g. 'virtio')"
}

variable "vm_storage_pool" {
  type        = string
  description = "The name of the Proxmox storage pool to store the VM template. (e.g. 'local-lvm')"
}

variable "vm_disk_format" {
  type        = string
  description = "The format of the file backing the disk. (e.g. 'qcow2')"
}

variable "vm_storage" {
  description = "Unified storage definition for template builds"

  type = object({
    disks = list(object({
      device       = string
      size         = string           # disk size (e.g., "32G")
      storage_pool = string           # Proxmox storage pool
      partitions   = list(object({
        role       = string
        size       = number
        vg         = string
        filesystem = object({
          fstype  = string
          label   = string
          mount   = string
          options = string
        })
      }))
    }))

    volume_groups = list(object({
      name            = string
      logical_volumes = list(object({
        name       = string
        size       = number
        filesystem = object({
          fstype  = string
          label   = string
          mount   = string
          options = string
        })
      }))
    }))
  })

  # -----------------------------------------
  # Partition role validation
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      contains(["efi","pv","swap","bios_grub","filesystem"], p.role)
    ])
    error_message = "Partition role must be one of: efi, pv, swap, bios_grub, filesystem."
  }

  # -----------------------------------------
  # Filesystem type validation
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      contains(["ext4","xfs","fat32","swap",""], p.filesystem.fstype)
    ])
    error_message = "Filesystem type must be ext4, xfs, fat32, swap, or empty."
  }

  # -----------------------------------------
  # Grow partition and volume validation (ADR-0002)
  # -----------------------------------------
  validation {
    condition = alltrue([
      for d in var.vm_storage.disks :
      length([for p in d.partitions : p.size if p.size == -1]) <= 1
    ])

    error_message = "Each disk may have only one grow partition."
  }

  validation {
    condition = alltrue([
      for vg in var.vm_storage.volume_groups :
      length([for lv in vg.logical_volumes : lv.size if lv.size == -1]) <= 1
    ])

    error_message = "ADR-0002: Each Volume Group (VG) may have only one 'grow' Logical Volume (size = -1)."
  }

  # -----------------------------------------
  # PV rules
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.role == "pv" ? p.vg != null : p.vg == null
    ])

    error_message = "PV partitions must define vg; other partitions must not."
  }

  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.role == "pv" ?
        contains([for vg in var.vm_storage.volume_groups : vg.name], p.vg)
      : true
    ])

    error_message = "PV references a volume group that is not defined."
  }

  # -----------------------------------------
  # EFI / BIOS GRUB partition validation
  # -----------------------------------------
  validation {
    condition = length([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) : p if p.role == "efi"
    ]) <= 1

    error_message = "Only one EFI partition is allowed."
  }

  validation {
    condition = length([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) : p if p.role == "bios_grub"
    ]) <= 1

    error_message = "Only one bios_grub partition is allowed."
  }

  validation {
    condition = alltrue(flatten([
      for d in var.vm_storage.disks : [
        for p in d.partitions :
        p.role == "bios_grub" ? p.size <= 2 : true
      ]
    ]))
    error_message = "BIOS_GRUB partitions (role 'bios_grub') must be 2MB or smaller."
  }

  # -----------------------------------------
  # Swap partition must use swap fs
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.role == "swap" ? p.filesystem.fstype == "swap" : true
    ])

    error_message = "Partitions with role 'swap' must use filesystem type 'swap'."
  }

  # -----------------------------------------
  # /boot rules
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.filesystem.mount == "/boot" ? p.size >= 512 : true
    ])

    error_message = "/boot must be at least 512 MB."
  }

  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.filesystem.mount == "/boot" ? p.role != "pv" : true
    ])

    error_message = "/boot cannot reside inside an LVM physical volume."
  }

  validation {
    condition = alltrue(flatten([
      for vg in var.vm_storage.volume_groups : [
        for lv in vg.logical_volumes : lv.filesystem.mount != "/boot"
      ]
    ]))
    error_message = "/boot must be a physical partition and cannot be a Logical Volume."
  }

  # -----------------------------------------
  # /boot/efi rules
  # -----------------------------------------
  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.filesystem.mount == "/boot/efi" ? p.role == "efi" : true
    ])

    error_message = "/boot/efi must use role 'efi'."
  }

  validation {
    condition = alltrue([
      for p in flatten([
        for d in var.vm_storage.disks : d.partitions
      ]) :
      p.filesystem.mount == "/boot/efi" ? contains(["fat32","vfat"], p.filesystem.fstype) : true
    ])

    error_message = "/boot/efi must use filesystem type fat32."
  }

  validation {
    condition = anytrue([
      for p in flatten([for d in var.vm_storage.disks : d.partitions]) : p.role == "efi"
    ]) || anytrue([
      for p in flatten([for d in var.vm_storage.disks : d.partitions]) : p.role == "bios_grub"
    ])
    error_message = "A bootloader helper partition (role 'efi' or 'bios_grub') must be defined."
  }

  # -----------------------------------------
  # Prevent duplicate mountpoints
  # -----------------------------------------
  validation {
    condition = (
      length(distinct([
        for p in flatten([
          for d in var.vm_storage.disks : d.partitions
        ]) :
        p.filesystem.mount if p.filesystem.mount != ""
      ]))
      ==
      length([
        for p in flatten([
          for d in var.vm_storage.disks : d.partitions
        ]) :
        p.filesystem.mount if p.filesystem.mount != ""
      ])
    )

    error_message = "Duplicate mountpoints detected in partitions."
  }

  # -----------------------------------------
  # Volume Group validations
  # -----------------------------------------
  validation {
    condition = alltrue([
      for vg in distinct([
        for p in flatten([
          for d in var.vm_storage.disks : d.partitions
        ]) : p.vg if p.role == "pv"
      ]) :
      length([
        for p in flatten([
          for d in var.vm_storage.disks : d.partitions
        ]) : p if p.role == "pv" && p.vg == vg
      ]) > 0
    ])

    error_message = "Each volume group referenced by a PV must have at least one PV partition."
  }

  validation {
    condition = (
      length(var.vm_storage.volume_groups) > 0 ||
      alltrue([
        for d in var.vm_storage.disks :
        alltrue([
          for p in d.partitions :
          p.vg == null
        ])
      ])
    )
    error_message = "Partitions cannot reference a volume group when none are defined."
  }

  validation {
    condition = (
      length(var.vm_storage.volume_groups) == 0 ||
      length(flatten([
        for d in var.vm_storage.disks :
        [for p in d.partitions : p.vg if p.vg != null]
      ])) > 0
    )
    error_message = "Volume groups are defined but not used by any partition."
  }

  validation {
    condition = (
      length(distinct([
        for vg in var.vm_storage.volume_groups : vg.name
      ])) ==
      length(var.vm_storage.volume_groups)
    )

    error_message = "Volume group names must be unique."
  }

}
