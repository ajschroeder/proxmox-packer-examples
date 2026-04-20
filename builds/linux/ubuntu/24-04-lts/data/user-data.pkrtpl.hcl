#cloud-config
autoinstall:
  version: 1
  apt:
    geoip: true
  locale: ${vm_os_language}
  keyboard:
    layout: ${vm_os_keyboard}
  storage:
    config:
      ${indent(6, trimspace(storage))}
  network:
    network:
      ${indent(6, trimspace(network))}
  identity:
    hostname: ubuntu-server
    username: ${build_username}
    password: ${build_password_encrypted}
  ssh:
    install-server: true
    allow-pw: true
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - openssh-server
    - qemu-guest-agent
    - cloud-init
%{ for package in additional_packages ~}
    - ${package}
%{ endfor ~}
  user-data:
    disable_root: false
    timezone: ${vm_os_timezone}
  late-commands:
    - curtin in-target -- sh -c "echo 'deploy ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/deploy"
    - curtin in-target -- chmod 440 /etc/sudoers.d/deploy
    - curtin in-target -- systemctl enable qemu-guest-agent
