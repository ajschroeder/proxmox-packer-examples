resource "proxmox_vm_qemu" "main" {
    target_node = "pve"
    name = var.vmname
    vmid = var.vm_id
    os_type = "cloud-init"
    bios = "ovmf" # to use UEFI
    # The template name to clone this vm from
    clone = var.templatename
    # Activate QEMU agent for this VM
    agent = 1

    sockets = var.cpu_sockets
    vcpus = 0
    memory = 8192

    network {
        id = 0
        model = "virtio"
        bridge = var.virt_switch
        tag = var.vlantag
        firewall = false
    
     }

    # cloudinit_cdrom_storage = "primary"
    scsihw   = "virtio-scsi-single" 
    boot     = "order=sata0;net0"
    bootdisk = "sata0"
    
    disk {
       storage = var.disk_datastore
       size    = var.disk_size
       slot    = "sata0"
     }

    # Cloud-init options
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = var.ipconfig_set
    ciuser = var.cloud_user
    sshkeys = file(var.pub_ssh_key_path)

}
