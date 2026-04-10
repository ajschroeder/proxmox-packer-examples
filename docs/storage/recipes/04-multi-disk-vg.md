# Storage Recipe: Multi-Disk Volume Group

Represents Test #7 – Multi-disk VG

Multiple disks combined into a single LVM pool.

## When to Use

- You want a single large logical storage pool
- Flexible resizing and allocation
- Good for databases or general-purpose servers

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
      size         = "32G"
      device       = "vdb"
      storage_pool = "local-zfs"

      partitions = [
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
          size = 10240
          filesystem = {
            fstype  = "ext4"
            label   = "ROOT"
            mount   = "/"
            options = ""
          }
        },
        {
          size = 4096
          name = "swap"
          filesystem = {
            fstype  = "swap"
            label   = ""
            mount   = ""
            options = ""
          }
        },
      ]
    }
  ]
}
```
