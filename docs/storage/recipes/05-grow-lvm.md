# Storage Recipe: Grow-to-Fill LVM (Single Disk)

Represents Test #15 – PV grow

This maximizes disk utilization dynamically.

## When to Use

- Template will be resized after deployment
- Cloud or Proxmox environments with variable disk sizes
- You want “use all available space” behavior

## Storage Definition
```hcl
vm_firmware = "ovmf"

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
        }
      ]
    }
  ]
}
```
