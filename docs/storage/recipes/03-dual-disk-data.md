# Storage Recipe: Dual Disk (LVM + Separate Data Disk)

Represents Test #5 – Reference implementation

This separates OS and data cleanly.

## When to Use

- You want OS isolated from data
- Easier backup/restore strategies
- Common for homelab services


## Storage Definition

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
    },
    {
      size         = "100G"
      device       = "vdb"
      storage_pool = "local-lvm"

      partitions = [
        {
          size = -1
          role = "filesystem"
          vg   = null
          filesystem = {
            fstype  = "xfs"
            label   = "DATAFS"
            mount   = "/data"
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
