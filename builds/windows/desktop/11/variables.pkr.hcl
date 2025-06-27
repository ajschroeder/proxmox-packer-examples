/*
    DESCRIPTION:
    Microsoft Windows 11 input variables.
    Packer Plugin for Proxmox: 'proxmox-iso' builder.
*/

//  BLOCK: variable
//  Defines the input variables.

// Proxmox Credentials

variable "proxmox_hostname" {
  type        = string
  description = "The FQDN or IP address of a Proxmox node. Only one node should be specified in a cluster."
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The token to login to the Proxmox node/cluster. The format is USER@REALM!TOKENID. (e.g. packer@pam!packer_pve_token)"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The secret for the API token used to login to the Proxmox API."
#  sensitive   = true
}

variable "proxmox_insecure_connection" {
  description = "true/false to skip Proxmox TLS certificate checks."
  type        = bool
  default     = true
}

// Proxmox Settings

variable "proxmox_node" {
  type    = string
  description = "The name of the Proxmox node that Packer will build templates on."
}

// Installer Settings

variable "vm_inst_os_language" {
  type        = string
  description = "The installation operating system lanugage."
  default     = "en-US"
}

variable "vm_inst_os_keyboard" {
  type        = string
  description = "The installation operating system keyboard input."
  default     = "en-US"
}

variable "vm_inst_os_eval" {
  type        = bool
  description = "Build using the operating system evaluation"
  default     = true
}

variable "vm_inst_os_image_pro" {
  type        = string
  description = "The installation operating system image input.\nDoes not support evaluation."
  default     = "Windows 11 Pro"
}

variable "vm_inst_os_image_ent" {
  type        = string
  description = "The installation operating system image input. Does support evaluation."
  default     = "Windows 11 Enterprise"
}

variable "vm_inst_os_key_pro" {
  type        = string
  description = "The installation operating system key input."
}
variable "vm_inst_os_key_ent" {
  type        = string
  description = "The installation operating system key input."
}

// Virtual Machine Settings

variable "vm_os_language" {
  type        = string
  description = "The guest operating system lanugage."
  default     = "en-US"
}

variable "vm_os_keyboard" {
  type        = string
  description = "The guest operating system keyboard input."
  default     = "en-US"
}

variable "vm_os_timezone" {
  type        = string
  description = "The guest operating system timezone."
  default     = "UTC"
}

variable "vm_os_family" {
  type        = string
  description = "The guest operating system family. Used for naming. (e.g. 'linux')"
  default     = "windows"
}

variable "vm_os_name" {
  type        = string
  description = "The guest operating system name. Used for naming."
  default     = "desktop"
}

variable "vm_os_version" {
  type        = string
  description = "The guest operating system version. Used for naming."
}

variable "vm_os_edition_pro" {
  type        = string
  description = "The guest operating system edition. Used for naming."
}

variable "vm_os_edition_ent" {
  type        = string
  description = "The guest operating system edition. Used for naming."
}

variable "vm_os_type" {
  type        = string
  description = "The guest operating system type, also know as guestid."
}

variable "vm_bios" {
  type        = string
  description = "The firmware type. Allowed values 'ovmf' or 'seabios'"
  default     = "ovmf"
  validation {
    condition     = contains(["ovmf", "seabios"], var.vm_bios)
    error_message = "The vm_bios value must be 'ovmf' or 'seabios'."
  }
}

variable "vm_firmware_path" {
  type        = string
  description = "The firmware file to be used. Needed for EFI"
  default     = "/usr/share/ovmf/OVMF.fd"
}

variable "vm_efi_storage_pool" {
  type        = string
  description = "Set the UEFI disk storage location. (e.g. 'local')"
  default     = "local"
}

variable "vm_efi_type" {
  type        = string
  description = "Specifies the version of the OVMF firmware to be used. (e.g. '4m')"
  default     = "4m"
}

variable "vm_efi_pre_enrolled_keys" {
  type        = bool
  description = "Whether Microsoft Standard Secure Boot keys should be pre-loaded on the EFI disk. (e.g. false)"
  default     = false
}

variable "vm_machine_type" {
  type        = string
  description = "Set the machine type. Supported values are 'pc' or 'q35'."
  default     = "pc"
  validation {
    condition     = contains(["pc", "q35"], var.vm_machine_type)
    error_message = "The vm_machine_type value must be 'pc' or 'q35'."
  }
}
variable "vm_cpu_count" {
  type        = number
  description = "The number of virtual CPUs."
  default     = 2
}

variable "vm_cpu_sockets" {
  type        = number
  description = "The number of virtual CPU sockets. (e.g. '1')"
}

variable "vm_cpu_type" {
  type        = string
  description = "The CPU type to emulate. See the Proxmox API documentation for the complete list of accepted values. For best performance, set this to host. Defaults to kvm64."
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB."
  default     = 4096
}

variable "vm_tpm_storage_pool" {
  type        = string
  description = "Storage location virtual trusted platform module (vTPM)."
}

variable "vm_tpm_version" {
  type        = string
  description = "Version of virtual trusted platform module (vTPM). Can be 'v1.2' or 'v2.0' Defaults to 'v2.0'"
  default     = "v2.0"
}

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
  description = "The name of the Proxmox storage pool to store the VM template. (e.g. 'local')"
}

variable "vm_disk_size" {
  type        = string
  description = "The size for the virtual disk in GB. (e.g. '32G')"
}

variable "vm_disk_format" {
  type        = string
  description = "The format of the file backing the disk. (e.g. 'qcow2')"
}

variable "vm_network_card_model" {
  type        = string
  description = "The model of the virtual network adapter to emulate. (e.g. 'virtio')"
}

variable "vm_bridge_interface" {
  type        = string
  description = "The name of the Proxmox bridge to attach the adapter to."
}

variable "vm_vlan_tag" {
  type        = string
  description = "If the adapter should tag packets, give the VLAN ID. (e.g. '102')"
}

variable "vm_video_ram" {
  type        = number
  description = "The size for the video memory in KB."
  default     = 4096
}

variable "vm_video_displays" {
  type        = number
  description = "The number of video displays."
  default     = 1
}

// Removable Media Settings

variable "common_iso_storage" {
  type        = string
  description = "The name of the source Proxmox storage location for ISO images. (e.g. 'local')"
}

variable "iso_path" {
  type        = string
  description = "The path on the source Proxmox storage location for ISO images. (e.g. 'iso')"
}

variable "iso_file" {
  type        = string
  description = "The file name of the ISO image used by the vendor. (e.g. 'ubuntu-<version>-live-server-amd64.iso')"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum value of the ISO image provided by the vendor."
}

// Boot Settings

variable "common_data_source" {
  type        = string
  description = "The provisioning data source. One of `http` or `disk`."
}

variable "common_http_bind_address" {
  type        = string
  description = "Define an IP address on the host to use for the HTTP server."
  default     = null
}

variable "common_http_interface" {
  type        = string
  description = "Name of the network interface that Packer gets HTTPIP from. Defaults to the first non loopback interface."
  default     = null
}

variable "common_http_port_min" {
  type        = number
  description = "The start of the HTTP port range."
}

variable "common_http_port_max" {
  type        = number
  description = "The end of the HTTP port range."
}

variable "vm_boot_order" {
  type        = string
  description = "The boot order for virtual machines devices."
}

variable "vm_boot_wait" {
  type        = string
  description = "The time to wait before boot."
  default     = "5s"
}

variable "vm_boot_command" {
  type        = list(string)
  description = "The virtual machine boot command."
  default     = ["<spacebar><spacebar>"]
}

variable "common_ip_wait_timeout" {
  type        = string
  description = "Time to wait for guest operating system IP address response."
}

variable "common_shutdown_timeout" {
  type        = string
  description = "Time to wait for guest operating system shutdown."
}

// Communicator Settings and Credentials

variable "build_username" {
  type        = string
  description = "The username to login to the guest operating system."
  sensitive   = true
}

variable "build_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}

variable "build_password_encrypted" {
  type        = string
  description = "The SHA-512 encrypted password to login to the guest operating system."
  sensitive   = true
  default     = ""
}

variable "build_key" {
  type        = string
  description = "The public key to login to the guest operating system."
  sensitive   = true
  default     = ""
}

// Communicator Credentials

variable "communicator_port" {
  type        = number
  description = "The port for the communicator protocol."
  default     = 5985
}

variable "communicator_timeout" {
  type        = string
  description = "The timeout for the communicator protocol."
  default     = "12h"
}

// Ansible Credentials

variable "ansible_username" {
  type        = string
  description = "The username for Ansible to login to the guest operating system."
  sensitive   = true
}

variable "ansible_key" {
  type        = string
  description = "The public key for Ansible to login to the guest operating system."
  sensitive   = true
}

// Provisioner Settings

variable "scripts" {
  type        = list(string)
  description = "A list of scripts and their relative paths to transfer and run."
  default     = []
}

variable "inline" {
  type        = list(string)
  description = "A list of commands to run."
  default     = []
}

// HCP Packer Settings

variable "common_hcp_packer_registry_enabled" {
  type        = bool
  description = "Enable the HCP Packer registry."
  default     = false
}

variable "vm_id_number" {
  type        = string
  description = "standardized template number."
  default = "10000"
}