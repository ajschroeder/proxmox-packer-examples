/*
    DESCRIPTION:
    Ubuntu Server 24.04 LTS template using the Packer Builder for Proxmox (proxmox-iso).
*/

//  BLOCK: packer
//  The Packer configuration.

packer {
  required_version = ">= 1.9.1"
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    git = {
      version = ">= 0.4.2"
      source  = "github.com/ethanmdavidson/git"
    }
    proxmox = {
      version = ">= 1.0.6"
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
  bios_boot_command = [
    "c<wait5>",
    "linux /casper/vmlinuz --- autoinstall ${local.data_source_command}",
    "<enter><wait10>",
    "initrd /casper/initrd",
    "<enter><wait10>",
    "boot",
    "<enter>"
  ]
  uefi_boot_command = [
    // This waits for 3 seconds, sends the "c" key, and then waits for another 3 seconds. In the GRUB boot loader, this is used to enter command line mode.
    "<wait3s>c<wait3s>",
    // This types a command to load the Linux kernel from the specified path with the 'autoinstall' option and the value of the 'data_source_command' local variable.
    // The 'autoinstall' option is used to automate the installation process.
    // The 'data_source_command' local variable is used to specify the kickstart data source configured in the common variables.
    "linux /casper/vmlinuz --- autoinstall ${local.data_source_command}",
    // This sends the "enter" key and then waits. This is typically used to execute the command and give the system time to process it.
    "<enter><wait>",
    // This types a command to load the initial RAM disk from the specified path.
    "initrd /casper/initrd",
    // This sends the "enter" key and then waits. This is typically used to execute the command and give the system time to process it.
    "<enter><wait>",
    // This types the "boot" command. This starts the boot process using the loaded kernel and initial RAM disk.
    "boot",
    // This sends the "enter" key. This is typically used to execute the command.
    "<enter>"
  ]
  build_by          = "Built by: HashiCorp Packer ${packer.version}"
  build_date        = formatdate("DD-MM-YYYY hh:mm ZZZ", "${timestamp()}" )
  build_version     = data.git-repository.cwd.head
  build_description = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}\nCloud-Init: ${var.vm_cloudinit}"
  vm_disk_type      = var.vm_disk_type == "virtio" ? "vda" : "sda"
  manifest_date     = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path     = "${path.cwd}/manifests/"
  manifest_output   = "${local.manifest_path}${local.manifest_date}.json"
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/data/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      build_username           = var.build_username
      build_password           = var.build_password
      build_password_encrypted = var.build_password_encrypted
      vm_disk_type             = local.vm_disk_type
      vm_os_language           = var.vm_os_language
      vm_os_keyboard           = var.vm_os_keyboard
      vm_os_timezone           = var.vm_os_timezone

      network                  = templatefile("${abspath(path.root)}/data/network.pkrtpl.hcl", {
        device                 = var.vm_network_device
        ip                     = var.vm_ip_address
        netmask                = var.vm_ip_netmask
        gateway                = var.vm_ip_gateway
        dns                    = var.vm_dns_list
      })
      storage                  = templatefile("${abspath(path.root)}/data/storage.pkrtpl.hcl", {
        device                 = var.vm_disk_device
        swap                   = var.vm_disk_use_swap
        partitions             = var.vm_disk_partitions
        lvm                    = var.vm_disk_lvm
        vm_bios                = var.vm_bios
      })
      additional_packages = var.additional_packages
    })
  }
  data_source_command = var.common_data_source == "http" ? "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"" : "ds=\"nocloud\""
  vm_name = "${var.vm_os_family}-${var.vm_os_name}-${var.vm_os_version}"
  boot_command = var.vm_bios == "ovmf" ? local.uefi_boot_command : local.bios_boot_command
  vm_bios = var.vm_bios == "ovmf" ? var.vm_firmware_path : null
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "proxmox-iso" "ubuntu" {
 
  // Proxmox Connection Settings and Credentials
  proxmox_url              = "https://${var.proxmox_hostname}:8006/api2/json"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = "${var.proxmox_insecure_connection}"

  // Proxmox Settings
  node                     = "${var.proxmox_node}"

  // Virtual Machine Settings
  vm_name         = "${local.vm_name}"
  bios            = "${var.vm_bios}"
  sockets         = "${var.vm_cpu_sockets}"
  cores           = "${var.vm_cpu_count}"
  cpu_type        = "${var.vm_cpu_type}"
  memory          = "${var.vm_mem_size}"
  os              = "${var.vm_os_type}"
  scsi_controller = "${var.vm_disk_controller_type}"
  disks {
    disk_size     = "${var.vm_disk_size}"
    type          = "${var.vm_disk_type}"
    storage_pool  = "${var.vm_storage_pool}"
    format        = "${var.vm_disk_format}"
  }
  dynamic "efi_config" {
    for_each = var.vm_bios == "ovmf" ? [1] : []
    content {
      efi_storage_pool  = var.vm_bios == "ovmf" ? var.vm_efi_storage_pool : null
      efi_type          = var.vm_bios == "ovmf" ? var.vm_efi_type : null
      pre_enrolled_keys = var.vm_bios == "ovmf" ? var.vm_efi_pre_enrolled_keys : null
    }
  }
  unmount_iso     = true
  ssh_username    = "${var.build_username}"
  ssh_password    = "${var.build_password}"
  ssh_timeout     = "${var.timeout}"
  ssh_port        = "22"
  iso_file        = "${var.common_iso_storage}:${var.iso_path}/${var.iso_file}"
  iso_checksum    = "${var.iso_checksum}"
  qemu_agent      = true

  network_adapters {
    bridge     = "${var.vm_bridge_interface}"
    model      = "${var.vm_network_card_model}"
    vlan_tag   = "${var.vm_vlan_tag}"
  }

  // Removable Media Settings
  http_content = "${var.common_data_source}" == "http" ? "${local.data_source_content}" : null

  // Boot and Provisioning Settings
  http_bind_address = var.common_data_source == "http" ? var.common_http_bind_address : null
  http_port_min     = var.common_data_source == "http" ? var.common_http_port_min : null
  http_port_max     = var.common_data_source == "http" ? var.common_http_port_max : null
  boot              = var.vm_boot
  boot_wait         = var.vm_boot_wait
  boot_command      = local.boot_command

  dynamic "additional_iso_files" {
    for_each = var.common_data_source == "disk" ? [1] : []
    content {
      cd_files = var.common_data_source == "disk" ? local.data_source_content : null
      cd_label = var.common_data_source == "disk" ? "cidata" : null
      iso_storage_pool = var.common_data_source == "disk" ? "local" : null
    }
  }

  template_name        = "${local.vm_name}"
  template_description = "${local.build_description}"

  # VM Cloud Init Settings
  cloud_init              = var.vm_cloudinit
  cloud_init_storage_pool = var.vm_cloudinit == true ? var.vm_storage_pool : null

}

# Build Definition to create the VM Template
build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "ansible" {
    user                   = var.build_username
    galaxy_file            = "${path.cwd}/ansible/linux-requirements.yml"
    galaxy_force_with_deps = true
    playbook_file          = "${path.cwd}/ansible/linux-playbook.yml"
    roles_path             = "${path.cwd}/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg",
      "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
    ]
    extra_arguments = [
      "--extra-vars", "display_skipped_hosts=false",
      "--extra-vars", "build_username=${var.build_username}",
      "--extra-vars", "build_key='${var.build_key}'",
      "--extra-vars", "ansible_username=${var.ansible_username}",
      "--extra-vars", "ansible_key='${var.ansible_key}'",
      "--extra-vars", "enable_cloudinit='${var.vm_cloudinit}'",
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
      vm_cloudinit             = "${var.vm_cloudinit}"
    }
  }
}
