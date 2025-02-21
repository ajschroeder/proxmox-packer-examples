/*
    DESCRIPTION:
    Microsoft Windows 11 variables used by the Packer Plugin for Proxmox (proxmox-iso).
*/

// Guest Operating System Metadata
vm_os_language   = "en_US"
vm_os_keyboard   = "us"
vm_os_timezone   = "UTC"

// Virtual Machine Guest Operating System Setting
vm_os_type       = "win11"

// Machine type
// Q35 less resource overhead and newer chipset
vm_machine_type         = "q35"

// Virtual Machine Hardware Settings
vm_bios                 = "ovmf"
vm_cpu_count            = 2
vm_cpu_sockets          = 1
vm_cpu_type             = "x86-64-v2-AES"
vm_mem_size             = 4096
vm_disk_type            = "virtio"
vm_disk_size            = "32G"
vm_disk_format          = "raw"
vm_disk_controller_type = "virtio-scsi-single"
vm_network_card_model   = "virtio"

// Removable Media Settings
iso_path     = "iso"
iso_file     = "22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum = ""

// Boot Settings
vm_boot_order = "order=virtio0;ide2;net0"

// EFI Settings
vm_efi_storage_pool = "pool0"
vm_firmware_path    = "./OVMF.fd"

// TPM Settings
vm_tpm_storage_pool = "pool0"
