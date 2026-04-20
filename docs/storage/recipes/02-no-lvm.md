# Storage Recipe: No LVM (Single Disk, Partition Only)

Represents Test #4 – No LVM build

This is the simplest possible layout: no LVM, just standard partitions.

## When to Use

- You want maximum simplicity
- You don’t need LVM flexibility
- You’re building minimal or appliance-style systems

## Storage Definition

> **Note**
>
> Partitions in this recipe are not part of any volume group.
> The `vg` field must be set to `null`, not an empty string.
>
> ```hcl
> vg = null
> ```
>
> Using `""` may pass basic validation but can lead to inconsistent behavior during normalization and rendering.

```hcl
vm_firmware              = "ovmf"
vm_efi_storage_pool      = "local-zfs"
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
          vg   = null
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
          vg   = null
          filesystem = {
            fstype  = "xfs"
            label   = "BOOT"
            mount   = "/boot"
            options = ""
          }
        },
        {
          size = 2048
          role = "swap"
          vg   = null
          filesystem = {
            fstype  = "swap"
            label   = "SWAPFS"
            mount   = ""
            options = ""
          }
        },
        {
          size = -1
          role = "filesystem"
          vg   = null
          filesystem = {
            fstype  = "xfs"
            label   = "ROOT"
            mount   = "/"
            options = ""
          }
        }
      ]
    }
  ]
  # Required by Packer type system even when unused
  volume_groups = []
}
```
