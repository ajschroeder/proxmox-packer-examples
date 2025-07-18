variable "proxmox_api_url" {
 description = "Proxmox API Url"
 type        = string
 default     = "https://192.168.1.2:8006/api2/json"
}

variable "proxmox_token_secret" {
 description = "proxmox token secret"
 type        = string
 sensitive   = true
}

variable "token_id" {
 description = "proxmox token id"
 type        = string
 sensitive   = true
}

variable "cpu_sockets" {
 description = "Number of sockets for VM"
 type        = string
 default     = "2"
}

variable "vmname" {
 description = "name of virtual machine"
 type        = string
 }

variable "vm_id" {
 description = "proxmox vm id you would like to set, use 0 for first available"
 type        = string
 default     = "0"
}

variable "templatename" {
 description = "Proxmox cloud init template you would like to use"
 type        = string
 }

variable "ram_amount" {
 description = "How much RAM"
 type        = string
 default     = "4096"
}

variable "vlantag" {
 description = "THe vlan you would like the network on, leave blank for none"
 type        = string
 default     = "Default string value for this variable"
}

variable "virt_switch" {
 description = "what virtual switch you want it the vm on"
 type        = string
 default     = "vmbr0"
}

variable "disk_datastore" {
 description = "which datastore the primary disk will reside on"
 type        = string
 default     = "local-lvm"
}

variable "disk_size" {
 description = "Primary disk size (in GB)"
 type        = string
 default     = "30G"
}

variable "ipconfig_set" {
 description = "ipconfig statment example 'ip=192.168.1.5/24,gw=192.168.1.1' or leave as dhcp"
 type        = string
 default     = "dhcp"
}

variable "cloud_user" {
 description = "Cloud-init user to configure"
 type        = string
 default     = "ubuntu"
}

variable "pub_ssh_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub" # Or a more specific path
}
