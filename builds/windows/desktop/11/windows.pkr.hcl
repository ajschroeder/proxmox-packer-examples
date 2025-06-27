/*
    DESCRIPTION:
    Microsoft Windows 11 build definition.
    Packer Plugin for Proxmox: 'proxmox-iso' builder.
*/

//  BLOCK: packer
//  The Packer configuration.

packer {
  required_version = ">= 1.12.0"
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    git = {
      version = ">= 0.6.2"
      source  = "github.com/ethanmdavidson/git"
    }
    proxmox = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

//  BLOCK: data
//  Defines the data sources.

data "git-repository" "cwd" {}

//  BLOCK: locals
//  Defines the local variables.

locals {
  build_by           = "Built by: HashiCorp Packer ${packer.version}"
  build_date         = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version      = data.git-repository.cwd.head
  build_description  = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
  manifest_date      = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path      = "${path.cwd}/manifests/"
  manifest_output    = "${local.manifest_path}${local.manifest_date}.json"
  vm_name_pro        = "${var.vm_os_family}-${var.vm_os_name}-${var.vm_os_version}-${var.vm_os_edition_pro}"
  vm_name_ent        = "${var.vm_os_family}-${var.vm_os_name}-${var.vm_os_version}-${var.vm_os_edition_ent}"
  bucket_name        = replace("${var.vm_os_family}-${var.vm_os_name}-${var.vm_os_version}", ".", "")
  bucket_description = "${var.vm_os_family} ${var.vm_os_name} ${var.vm_os_version}"
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "proxmox-iso" "windows-desktop-pro" {

  // Proxmox Connection Settings and Credentials
  proxmox_url              = "https://${var.proxmox_hostname}:8006/api2/json"
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_insecure_connection

  // Proxmox Settings
  node                     = var.proxmox_node

  // Virtual Machine Settings
  machine         = var.vm_machine_type
  vm_name         = local.vm_name_pro
  bios            = var.vm_bios
  sockets         = var.vm_cpu_sockets
  cores           = var.vm_cpu_count
  cpu_type        = var.vm_cpu_type
  memory          = var.vm_mem_size
  os              = var.vm_os_type
  qemu_agent      = true
  scsi_controller = var.vm_disk_controller_type
  vm_id           = var.vm_id_number

  disks {
    disk_size     = var.vm_disk_size
    type          = var.vm_disk_type
    storage_pool  = var.vm_storage_pool
    format        = var.vm_disk_format
  }

  network_adapters {
    bridge     = var.vm_bridge_interface
    model      = var.vm_network_card_model
    vlan_tag   = var.vm_vlan_tag
  }

  tpm_config {
    tpm_storage_pool = var.vm_tpm_storage_pool
    tpm_version      = var.vm_tpm_version
  }

  dynamic "efi_config" {
    for_each = var.vm_bios == "ovmf" ? [1] : []
    content {
      efi_storage_pool  = var.vm_bios == "ovmf" ? var.vm_efi_storage_pool : null
      efi_type          = var.vm_bios == "ovmf" ? var.vm_efi_type : null
      pre_enrolled_keys = var.vm_bios == "ovmf" ? var.vm_efi_pre_enrolled_keys : null
    }
  }

  # Windows Server ISO File
  boot_iso {
    iso_file     = "${var.common_iso_storage}:${var.iso_path}/${var.iso_file}"
    unmount      = true
    iso_checksum = var.iso_checksum
    type         = "ide"
    index        = 0
  }

  // Removable Media Settings
  additional_iso_files {
    iso_file         = "${var.common_iso_storage}:iso/virtio-win.iso"
    iso_storage_pool = var.common_iso_storage
    cd_label         = "VirtIO"
    unmount          = true
  }

  additional_iso_files {
    cd_files = [
      "${path.cwd}/scripts/${var.vm_os_family}/"
    ]
    cd_content = {
      "autounattend.xml" = templatefile("${abspath(path.root)}/data/autounattend.pkrtpl.hcl", {
        build_username       = var.build_username
        build_password       = var.build_password
        vm_inst_os_eval      = var.vm_inst_os_eval
        vm_inst_os_language  = var.vm_inst_os_language
        vm_inst_os_keyboard  = var.vm_inst_os_keyboard
        vm_inst_os_image     = var.vm_inst_os_image_pro
        vm_inst_os_key       = var.vm_inst_os_key_pro
        vm_guest_os_language = var.vm_os_language
        vm_guest_os_keyboard = var.vm_os_keyboard
        vm_guest_os_timezone = var.vm_os_timezone
      })
    }
    cd_label = "Unattend"
    iso_storage_pool = var.common_iso_storage
    unmount = true
  }

  // Boot and Provisioning Settings
  http_interface    = var.common_http_interface
  http_bind_address = var.common_http_bind_address
  http_port_min     = var.common_http_port_min
  http_port_max     = var.common_http_port_max
  boot_wait         = var.vm_boot_wait
  boot_command      = var.vm_boot_command

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_username = var.build_username
  winrm_password = var.build_password
  winrm_port     = var.communicator_port
  winrm_timeout  = var.communicator_timeout

  template_name        = local.vm_name_pro
  template_description = local.build_description

}

# Build Definition to create the VM Template
source "proxmox-iso" "windows-desktop-ent" {

  // Proxmox Connection Settings and Credentials
  proxmox_url              = "https://${var.proxmox_hostname}:8006/api2/json"
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_insecure_connection

  // Proxmox Settings
  node                     = var.proxmox_node

  // Virtual Machine Settings
  machine         = var.vm_machine_type
  vm_name         = local.vm_name_ent
  bios            = var.vm_bios
  sockets         = var.vm_cpu_sockets
  cores           = var.vm_cpu_count
  cpu_type        = var.vm_cpu_type
  memory          = var.vm_mem_size
  os              = var.vm_os_type
  qemu_agent      = true
  scsi_controller = var.vm_disk_controller_type

  disks {
    disk_size     = var.vm_disk_size
    type          = var.vm_disk_type
    storage_pool  = var.vm_storage_pool
    format        = var.vm_disk_format
  }

  network_adapters {
    bridge     = var.vm_bridge_interface
    model      = var.vm_network_card_model
    vlan_tag   = var.vm_vlan_tag
  }

  tpm_config {
    tpm_storage_pool = var.vm_tpm_storage_pool
    tpm_version      = var.vm_tpm_version
  }

  dynamic "efi_config" {
    for_each = var.vm_bios == "ovmf" ? [1] : []
    content {
      efi_storage_pool  = var.vm_bios == "ovmf" ? var.vm_efi_storage_pool : null
      efi_type          = var.vm_bios == "ovmf" ? var.vm_efi_type : null
      pre_enrolled_keys = var.vm_bios == "ovmf" ? var.vm_efi_pre_enrolled_keys : null
    }
  }

  # Windows Server ISO File
  boot_iso {

    iso_file     = "${var.common_iso_storage}:${var.iso_path}/${var.iso_file}"
    unmount      = true
    iso_checksum = var.iso_checksum
    type         = "ide"
    index        = 0
  }

  // Removable Media Settings
  additional_iso_files {
    iso_file         = "${var.common_iso_storage}:iso/virtio-win.iso"
    iso_storage_pool = var.common_iso_storage
    cd_label         = "VirtIO"
    unmount          = true
  }

  additional_iso_files {
    cd_files = [
      "${path.cwd}/scripts/${var.vm_os_family}/"
    ]
    cd_content = {
      "autounattend.xml" = templatefile("${abspath(path.root)}/data/autounattend.pkrtpl.hcl", {
        build_username       = var.build_username
        build_password       = var.build_password
        vm_inst_os_eval      = var.vm_inst_os_eval
        vm_inst_os_language  = var.vm_inst_os_language
        vm_inst_os_keyboard  = var.vm_inst_os_keyboard
        vm_inst_os_image     = var.vm_inst_os_image_ent
        vm_inst_os_key       = var.vm_inst_os_key_ent
        vm_guest_os_language = var.vm_os_language
        vm_guest_os_keyboard = var.vm_os_keyboard
        vm_guest_os_timezone = var.vm_os_timezone
      })
    }
    cd_label = "Unattend"
    iso_storage_pool = var.common_iso_storage
    unmount = true
  }

  // Boot and Provisioning Settings
  http_interface    = var.common_http_interface
  http_bind_address = var.common_http_bind_address
  http_port_min     = var.common_http_port_min
  http_port_max     = var.common_http_port_max
  boot_wait         = var.vm_boot_wait
  boot_command      = var.vm_boot_command

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_username = var.build_username
  winrm_password = var.build_password
  winrm_port     = var.communicator_port
  winrm_timeout  = var.communicator_timeout

  template_name        = local.vm_name_pro
  template_description = local.build_description

}
//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.proxmox-iso.windows-desktop-pro",
    "source.proxmox-iso.windows-desktop-ent",
  ]

  provisioner "ansible" {
    user                   = "${var.build_username}"
    galaxy_file            = "${path.cwd}/ansible/windows-requirements.yml"
    galaxy_force_with_deps = true
    use_proxy              = false
    playbook_file          = "${path.cwd}/ansible/windows-playbook.yml"
    roles_path             = "${path.cwd}/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg"
    ]
    extra_arguments = [
      "--extra-vars", "use_proxy=false",
      "--extra-vars", "ansible_connection=winrm",
      "--extra-vars", "ansible_user='${var.build_username}'",
      "--extra-vars", "ansible_password='${var.build_password}'",
      "--extra-vars", "ansible_port='${var.communicator_port}'",
      "--extra-vars", "build_username='${var.build_username}'",
    ]
  }

  post-processor "manifest" {
    output     = local.manifest_output
    strip_path = true
    strip_time = true
    custom_data = {
      ansible_username         = "${var.ansible_username}"
      build_username           = "${var.build_username}"
      build_date               = "${local.build_date}"
      build_version            = "${local.build_version}"
      common_data_source       = "${var.common_data_source}"
      vm_cpu_sockets           = "${var.vm_cpu_sockets}"
      vm_cpu_count             = "${var.vm_cpu_count}"
      vm_disk_size             = "${var.vm_disk_size}"
      vm_bios                  = "${var.vm_bios}"
      vm_os_type               = "${var.vm_os_type}"
      vm_mem_size              = "${var.vm_mem_size}"
      vm_network_card_model    = "${var.vm_network_card_model}"
    }
  }
}
