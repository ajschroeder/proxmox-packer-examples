# Ubuntu Server noble
# ---
# Packer Template to create an Ubuntu Server (noble) on Proxmox

# Variable Definitions
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
variable "pve_node" {
    type = string
}
variable "ssh_user" {
    type = string
}
variable "ssh_pass" {
    type = string
}
variable "ssh_key" {
    type = string
    sensitive = true
}
variable "storage" {
    type = string
}
variable "vlan" {
    type = string
    default = "20"
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-noble-docker" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.pve_node}"
    vm_id = "10000"
    vm_name = "ubuntu-server-noble-docker"
    template_description = "Ubuntu Server Noble (24.04) Image with Docker preinstalled"

    boot_iso {
      iso_file = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
      unmount = true
      }

    # VM System Settings
    qemu_agent = true
    onboot=true
    bios = "ovmf"

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "${var.storage}"
        type = "virtio"
    }
    efi_config {
        efi_storage_pool = "${var.storage}"
        efi_type = "4m"
        pre_enrolled_keys = false
    }
    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
        vlan_tag = "${var.vlan}"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.storage}"

    # PACKER Boot Commands
    boot_command = [
        "<wait3s>c<wait3s>",
        "s=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---",
        "<enter><wait>",
        "initrd /casper/initrd",
        "<enter><wait>",
        "boot",
        "<enter>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    http_port_min = 8802
    http_port_max = 8805

    ssh_username = "${var.ssh_user}"

    # (Option 1) Add your Password here
    #ssh_password = "${var.ssh_pass}"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "${var.ssh_key}"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-noble-docker"
    sources = ["source.proxmox-iso.ubuntu-server-noble-docker"]

    # provisioner "ansible" {
    # user          = var.ssh_user
    # playbook_file = "${path.cwd}/${var.ansible_provisioner_playbook_path}"
    # extra_arguments = [ "--scp-extra-args", "'-O'" ]
    # ansible_env_vars = [
    #   "ANSIBLE_CONFIG=${path.cwd}/ansible.cfg",
    #   "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
    # ]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
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

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
    
    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -s 'https://raw.githubusercontent.com/traefikturkey/onvoy/master/ubuntu/bash/docker_server_setup.sh?$(date +%s)' | /bin/bash -s | tee ~/docker_build.log'"
        ]
    }

}