# Storage Recipe: UEFI Baseline Single Disk LVM

This storage recipe defines a single-disk LVM layout for systems using UEFI (OVMF) firmware.

It represents the baseline configuration used throughout this repository and is the recommended starting point for most Linux templates.

## Overview

This layout provides:

- a standard GPT disk
- EFI system partition for UEFI boot
- a dedicated `/boot` partition for maximum compatibility
- a single LVM volume group (sysvg)
- logical volumes for:
  - root (/)
  - swap

This configuration is intentionally conservative to ensure compatibility across a wide range of Linux distributions.

## Design Notes

`/boot` as a Partition

`/boot` is defined as a standard partition, not a logical volume.

This is intentional:

- Not all distributions support /boot inside LVM
- Some installers have inconsistent behavior when /boot is logical
- Keeping /boot outside LVM improves portability

If your target distribution fully supports `/boot` inside LVM, you may safely:

- remove the `/boot` partition
- define it as a logical volume instead

### LVM Layout

- A single physical volume (PV) consumes remaining disk space
- One volume group (sysvg) is created
- Logical volumes:
  - `root` grows to fill available space
  - `swap` is fixed size

This keeps the layout simple while still allowing flexibility.

## Storage Definition

```hcl
//VM EFI Settings
vm_firmware              = "ovmf"
vm_efi_storage_pool      = "pool0"
vm_efi_type              = "4m"
vm_efi_pre_enrolled_keys = false

vm_storage = {
  disks = [
    {
      size         = "32G"
      device       = "vda"
      storage_pool = "local-zfs"
      partitions = [
        {
          size = 512
          role = "efi"
          vg   = ""
          filesystem = {
            fstype  = "fat32"
            label   = "EFI"
            mount   = "/boot/efi"
            options = ""
          }
        },
        {
          size = 1024
          role = "filesystem"
          vg   = ""
          filesystem = {
            fstype  = "ext4"
            label   = "BOOT"
            mount   = "/boot"
            options = ""
          }
        },
        {
          size = -1
          role = "pv"
          vg   = "sysvg"
          filesystem = {
            fstype  = ""
            label   = ""
            mount   = ""
            options = ""
          }
        }
      ]
    }
  ]

  volume_groups = [
    {
      name = "sysvg"
      logical_volumes = [
        {
          name = "root"
          size = -1
          filesystem = {
            fstype  = "ext4"
            label   = "ROOT"
            mount   = "/"
            options = ""
          }
        },
        {
          name = "swap"
          size = 4096
          filesystem = {
            fstype  = "swap"
            label   = ""
            mount   = ""
            options = ""
          }
        }
      ]
    }
  ]
}
```

## When to Use This Recipe

Use this configuration if you want:

- a safe default that works across distributions
- a simple LVM layout
- a single-disk VM
- a known-good baseline before experimenting with more complex layouts

## Related Scenarios

This recipe corresponds to:

- Test #1 in the Storage Validation Matrix
  - Baseline single disk LVM

## Suggested Modifications

Common adjustments:

- Increase disk size (size = "64G", etc.)
- Change filesystem type (ext4 → xfs)
- Adjust swap size or remove it entirely
- Move /boot into LVM (if supported)
