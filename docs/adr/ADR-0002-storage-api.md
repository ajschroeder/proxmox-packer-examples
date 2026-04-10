# ADR-0002: Storage API Contract for Template Builds

## Status

Accepted

**Decision Owner:** AJ Schroeder<br/>
**Date:** 03-16-2026 (Updated)

## Context

This repository builds Linux and Windows VM templates using Packer and Proxmox.

The Storage API defined in this document applies **only to Linux-based templates**.
Windows templates currently use a separate storage configuration model defined within their unattend configuration.

Historically, each OS template (Kickstart, Preseed, Autoinstall, Windows Unattend) defined its own storage configuration independently. This resulted in:

* duplicated storage logic across distributions
* inconsistent disk layouts
* tight coupling between installer configuration and infrastructure
* difficulty evolving storage patterns (LVM, partitioning, multi-disk)

To address this, a Storage API was introduced and has since evolved into a normalized, multi-disk storage model that:

* defines storage once using Packer variables
* drives both Proxmox disk provisioning and OS-level partitioning
* ensures consistent layouts across all templates

---

## Decision

All Linux builds MUST derive storage configuration from a single normalized storage plan generated in:
```hcl
locals-storage.pkr.hcl
```

Windows builds are explicitly excluded from this requirement and currently manage storage independently.

This storage plan is the canonical contract between:

* user-defined variables (vm_storage)
* Proxmox disk configuration
* OS installer rendering (Kickstart, Preseed, etc.)
* build metadata (manifest)

No Linux template or build may define storage logic outside of this contract.

### Decision Update (03-26-2026)
To maintain the stability of the Storage API, any build targeting BIOS firmware should default to a Single Disk, MBR (msdos) partition table where possible. Use of GPT on BIOS-based templates is considered "Best Effort" and may be deprecated.

### Installer Specifics & Divergence

While the Storage API provides a unified interface, the underlying OS installers exhibit varying levels of flexibility:

| Installer | OS | Characteristics |
| :--- | :--- | :--- |
| **Preseed (partman)** | **Debian** | **Reference Implementation.** Most restrictive and sensitive to alignment, partition ordering, and LVM naming. If a layout passes Debian validation, it is considered "Universal." |
| **Subiquity** | **Ubuntu** | **Forgiving.** High-level abstraction; handles complex LVM and multi-disk scenarios with internal heuristics. |
| **Kickstart (Anaconda)** | **Alma/Rocky** | **Robust.** Declarative and highly reliable for LVM and RAID. |

**Decision:** All new `vm_storage` features and recipes MUST be verified against the Debian Preseed renderer first. Debian is the "Minimum Common Denominator" for storage stability in this repository.

---

## Storage Model

### Primary Interface

Storage is defined using a single variable:
```hcl
var.vm_storage
```
This replaces legacy variables such as:

* `vm_disk_size`
* `vm_disk_layout`
* `vm_logical_volumes`

### Disk Definition
```hcl
vm_storage = {
  disks = [
    {
      id           = 0
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
        }
      ]
    }
  ]
}
```

## Key Concepts

### Multi-Disk Support

* Multiple disks are supported
* Disk ordering is preserved
* Each disk is assigned a deterministic device name (vda, vdb, etc.)

### Device Naming (Proxmox Scoped)

To ensure consistency between the Proxmox Infrastructure (Hypervisor) and the OS Installer (Guest), the Storage API strictly enforces VirtIO naming:

- **Bus Type:** `virtio-scsi-pci` (Required)
- **Device Prefix:** `vd`
- **Naming Logic:** Deterministic mapping based on disk index (0 = `vda`, 1 = `vdb`, etc.)

---

### Partition Roles & Firmware Requirements

| Role       | Purpose                   | Requirement / Constraint |
| :---       | :---                      | :--- |
| `efi`      | EFI System Partition      | **Required** if `vm_firmware = "ovmf"`. Must be `fat32`. |
| `bios_grub`| BIOS boot partition (GPT) | **Required** if `vm_firmware = "seabios"` AND using GPT. Max 2MB. |
| `pv`       | LVM physical volume       | Must define `vg` name. Multiple PVs can reference the same `vg`. |
| `filesystem`| Regular partition        | Used for `/boot` or non-LVM data disks. |

### Size Semantics

- **Positive Integer:** Fixed size in Megabytes (MB).
- **-1 (Grow):** - **Partitions:** Only one `-1` per physical disk.
    - **Logical Volumes:** Only one `-1` per Volume Group.
    - *Note:* In Multi-Disk LVM, it is common to have a `-1` PV on `vda` and a `-1` PV on `vdb` to consume all provided Proxmox storage.


### Storage Plan Normalization

The storage API produces a normalized structure:
```hcl
storage_plan = {
  disks            = normalized_disks
  proxmox_disks    = proxmox_disks
  lvm_enabled      = true
  volume_groups    = ["sysvg"]
  firmware         = var.vm_firmware
}
```

### Normalization Responsibilities
* assign disk IDs and device names
* validate layout constraints
* normalize filesystem types per OS requirements
* detect LVM usage
* generate Proxmox-compatible disk objects

### Proxmox Integration

Proxmox disk configuration is derived from the storage model:
```hcl
proxmox_disks = [
  {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = "local-lvm"
    format       = "raw"
  }
]
```

These are consumed by dynamic blocks in the builder.

### Installer Rendering

All Linux OS installers consume the same storage plan via:
```hcl
data/storage.pkrtpl.hcl
```

This template is responsible for translating the normalized model into:

Kickstart (RHEL, Rocky, Alma)

Preseed (Debian)

Autoinstall (Ubuntu)

No installer contains hard-coded partition logic.

### Default Architecture

Recommended layout:
```bash
Disk (GPT)
├─ EFI System Partition
└─ LVM PV
    └─ VG (sysvg)
        ├─ root (/)
        ├─ swap
        ├─ var (optional)
        └─ additional volumes
```

* `/boot` resides in / by default
* separate `/boot` is optional

### Firmware Support Matrix

| Firmware    | Support Level | Partitioning Requirement |
| :---        | :---          | :--- |
| **UEFI (OVMF)** | **Primary** | Requires `efi` role partition on the boot disk. |
| **BIOS** | **Maintenance**| Requires `bios_grub` role if the API generates a GPT label. Limited to "Simple/Direct" disk layouts. **LVM and GPT are not guaranteed** and my be disabled for specific installers (e.g. Subiquity) |

#### Requirements

* UEFI requires efi partition
* BIOS + GPT → requires bios_grub

### Validation Rules

The storage API MUST validate:
* disk size vs partition sizes
* only one growable partition per disk
* only one growable LV per VG
* required partitions based on firmware
* LVM consistency (PV <> VG <> LV)

Validation failures must occur at **plan time**, not install time.

### Manifest Integration

The storage configuration MUST be included in build metadata:
```hcl
manifest_metadata = {
  vm_disk_count     = length(local.proxmox_disks)
  vm_disks          = jsonencode(local.proxmox_disks)
  vm_storage_layout = jsonencode(var.vm_storage)
}
```
This ensures reproducibility and traceability.

### Windows Storage Model (Exception)

Windows templates do not currently consume the Storage API.

Instead, storage is defined within:

* `autounattend.xml`
* Packer builder configuration (disk size, type)

#### Rationale

* Windows disk configuration is tightly coupled to `autounattend.xml`
* Partitioning semantics differ significantly from Linux installers
* Current implementation prioritizes simplicity and reliability over unification

#### Future Consideration

Unifying Windows with the Storage API would require:

* translating `vm_storage` to Windows disk configuration
* generating `autounattend.xml` disk sections dynamically
* handling Windows-specific constraints (MSR partitions, recovery, etc.)

This is considered **out of scope for the current implementation.**

---

## Consequences

### Positive

* Single source of truth for storage
* Consistent layouts across all OS builds
* Supports multi-disk and advanced layouts
* Eliminates installer duplication
* Enables future automation (profiles, encryption)

### Negative

* Increased complexity in normalization logic
* Requires strict validation to prevent invalid configs
* Renderer templates must remain in sync with schema

---

## Future Improvements

Possible enhancements:

### Storage Profiles
```hcl
vm_profile = "standard"
```
Profiles generate storage automatically:

* `tiny`
* `standard`
* `database`
* `logging-heavy`

### Encryption Support

* LUKS
* TPM-backed unlock (future)

### Windows Support

Evaluate extending the Storage API to support Windows templates, though this is non-trivial due to differences in installer behavior.

Potentially extend storage rendering to support:

* multi-disk layouts

### Dynamic Partition Rendering

Fully generate installer partition sections from:
```hcl
vm_storage.disks[*].partitions
```
Eliminating remaining manual template logic.

---

## Summary

The Storage API defines a normalized, multi-disk storage contract that drives:

* Proxmox disk provisioning
* OS installer configuration
* build metadata

This approach eliminates duplication, enforces consistency, and enables scalable template generation across operating systems.
