packer {
  required_plugins {
    proxmox = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

//  BLOCK: data
//  Defines the data sources.

variable "proxmox_api_url" {
    type = string
}
variable "proxmox_api_token_id" {
    type = string
}
variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
variable "proxmox_node" {
    type = string
}
variable "vlan_tag" {
    type = string
    default = ""
}

variable "ssh_user" {
    type = string
}

variable "ssh_pass" {
    type = string
    sensitive = true
}

variable "ssh_private_key_file" {
    type = string
}

variable "build_key" {
    type = string
}

variable "build_passwd_local" {
    type = string
    sensitive = true
}

variable "ansible_provisioner_playbook_path" {
    type = string
    default = "ubuntu-packer-config.yml"
}
variable "storage" {
    type = string
}

locals {
  iso_path = "{{var.iso_path}}"
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/http/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/http/user-data", {
      ssh_user                 = "${var.ssh_user}"
      build_key                = "${var.build_key}"
      build_passwd	           = "${var.build_passwd_local}"
      }
    )
  }
  data_source_command = "ds=\"nocloud;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\""
}

source "proxmox-iso" "ubuntu-tpl" {

    proxmox_url = "${var.proxmox_api_url}"
    insecure_skip_tls_verify = true
    node = "${var.proxmox_node}"
    boot_iso {
      type = "scsi"
      iso_file = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
      unmount = true
    }
    vm_name = "ubuntu24-docker"
    template_description = "Ubuntu Server Noble (24.04) Image with Docker preinstalled"
    vm_id = 10000
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    os = "l26"
    bios = "ovmf"
    efi_config {
      efi_storage_pool  = "${var.storage}"
      pre_enrolled_keys = false
      efi_format        = "raw"
      efi_type          = "4m"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.storage}"  

    qemu_agent = true
    # tpm_config {
    #   tpm_version 	    = "v2.0"
    #   tpm_storage_pool  = "${var.storage}"
    # }
    cpu_type = "host"
    cores = "2"
    memory = "4096"
    scsi_controller = "virtio-scsi-pci"
    disks {
      type		          = "sata"
      disk_size         = "20G"
      storage_pool      = "${var.storage}"
      format		        = "raw"
    }
    network_adapters {
      bridge            = "vmbr0"
      vlan_tag          = "${var.vlan_tag}"
      model             = "virtio"
    }
    communicator        = "ssh"
    ssh_username        = "${var.ssh_user}"
    ssh_private_key_file = "${var.ssh_private_key_file}"
    ssh_timeout         = "30m"
    ssh_handshake_attempts = "1000"
    boot_command        = [
      "c", 
      "linux /casper/vmlinuz autoinstall ${local.data_source_command} ---", 
      "<enter><wait>", "initrd /casper/initrd<enter><wait>", 
      "boot<enter>"
      ]
    http_content        = local.data_source_content
}

build {
    sources = ["source.proxmox-iso.ubuntu-tpl"]

    # provisioner "ansible" {
    # user          = var.ssh_user
    # playbook_file = "${path.cwd}/${var.ansible_provisioner_playbook_path}"
    # extra_arguments = [ "--scp-extra-args", "'-O'" ]
    # ansible_env_vars = [
    #   "ANSIBLE_CONFIG=${path.cwd}/ansible.cfg",
    #   "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
    # ]
  # }
    provisioner "shell" {
      inline = [
          "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
          "sudo rm /etc/ssh/ssh_host_*",
          "sudo truncate -s 0 /etc/machine-id",
          "sudo apt -y autoremove --purge",
          "sudo apt -y clean",
          "sudo apt -y autoclean",
          "sudo cloud-init clean",
          "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
          "sudo sync"
      ]
  }
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -s 'https://raw.githubusercontent.com/traefikturkey/onvoy/master/ubuntu/bash/docker_server_setup.sh?$(date +%s)' | /bin/bash -s | tee ~/docker_build.log'"
        ]
    }

}

