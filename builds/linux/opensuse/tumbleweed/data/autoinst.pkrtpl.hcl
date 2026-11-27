${jsonencode({
  product = {
    id = "Tumbleweed"
  }
  hostname = {
    static = "localhost"
  }
  localization = {
    language = vm_os_language
    keyboard = vm_os_keyboard
    timezone = vm_os_timezone
  }
  user = {
    fullName       = "Build User"
    userName       = build_username
    password       = build_password_encrypted
    hashedPassword = true
  }
  access = {
    ssh = "enabled"
  }
  network = jsondecode(network)
  storage = jsondecode(storage)
  bootloader = {
    timeout = 5
  }
  software = {
    packages = concat([
      "openssh",
      "sudo",
      "lvm2",
      "qemu-guest-agent",
      "chrony",
      "firewalld"
    ], additional_packages)
  }
  scripts = {
    post = [
      {
        name    = "configure-build-user-and-services"
        chroot  = true
        content = <<-EOT
          #!/usr/bin/bash
          usermod -aG wheel ${build_username}
          echo '${build_username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/${build_username}
          chmod 0440 /etc/sudoers.d/${build_username}
          mkdir -p /etc/systemd/system/boot-relabel.service.d
          printf '[Unit]\nAfter=boot-efi.mount\n' > /etc/systemd/system/boot-relabel.service.d/10-after-boot-efi.conf
          systemctl enable sshd.service
          systemctl enable qemu-guest-agent.service
        EOT
      }
    ]
  }
})}
