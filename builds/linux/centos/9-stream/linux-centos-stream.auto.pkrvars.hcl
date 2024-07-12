/*
    DESCRIPTION:
    CentOS Stream 9 variables used by the Packer Plugin for Proxmox (proxmox-iso).
*/

// Guest Operating System Metadata
vm_os_language   = "en_US"
vm_os_keyboard   = "us"
vm_os_timezone   = "UTC"
vm_os_family     = "linux"
vm_os_name       = "centos-stream"
vm_os_version    = "9"

// Virtual Machine Guest Operating System Setting
vm_os_type       = "l26"
vm_cloudinit     = true

// Virtual Machine Hardware Settings
vm_bios                 = "ovmf"
vm_cpu_count            = 1
vm_cpu_sockets          = 1
vm_cpu_type             = "x86-64-v2-AES"
vm_mem_size             = 2048
vm_disk_type            = "virtio"
vm_disk_size            = "32G"
vm_disk_format          = "raw"
vm_disk_controller_type = "virtio-scsi-pci"
vm_network_card_model   = "virtio"

// Removable Media Settings
iso_path     = "iso"
iso_file     = "CentOS-Stream-9-latest-x86_64-dvd1.iso"
iso_checksum = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/SHA256SUM"

// Boot Settings
vm_boot      = "order=virtio0;ide2;net0"
vm_boot_wait = "5s"

// EFI Settings
vm_firmware_path         = "./OVMF.fd"
