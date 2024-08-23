%{~ if length(partitions) == 1 && partitions[0].name == "autopart" ~}
    %{~ if partitions[0].format.fstype == "lvm" ~}
  storage:
    layout:
      name: lvm
    %{~ endif ~}
    %{~ if partitions[0].format.fstype == "simple" ~}
  storage:
    layout:
      name: direct
    %{~ endif ~}
    %{~ if partitions[0].format.fstype == "" ~}
  storage:
    layout:
      name: direct
    %{~ endif ~}
%{~ else ~}
  storage:
    config:
      - ptable: gpt
        path: /dev/${device}
        wipe: superblock
        preserve: false
%{ if vm_bios == "seabios" ~}
        grub_device: true
%{ endif ~}
        type: disk
        id: disk-${device}
%{if vm_bios == "seabios" ~}
      - device: disk-${device}
        size: 1M
        flag: bios_grub
        number: 1
        preserve: false
        type: partition
        id: partition-grub
%{ endif ~}

%{ for index, partition in partitions ~}
      - device: disk-${device}
%{ if partition.size != -1 ~}
        size: ${partition.size}M
%{ else ~}
        size: ${partition.size}
%{ endif ~}
        wipe: superblock
        preserve: false
%{ if partition.mount.path == "/boot" && vm_bios == "seabios" && index == 0 ~}
        flag: bios_grub
        grub_device: false
%{ endif ~}
%{ if partition.mount.path == "/boot/efi" && index == 0 ~}
        flag: boot
        grub_device: true
%{ endif ~}
        type: partition
        id: partition-${partition.name}
%{ if partition.format.fstype != "" ~}
      - id: format-${partition.name}
        type: format
        volume: partition-${partition.name}
        label: ${partition.format.label}
        fstype: ${partition.format.fstype}
%{ endif ~}
%{ if partition.volume_group == "" && partition.name != "bios_grub" ~}
      - id: mount-${partition.name}
        type: mount
%{ if partition.mount.path == "" ~}
        path: none
%{ else ~}
        path: ${partition.mount.path}
%{ endif ~}
        device: format-${partition.name}
%{ if partition.mount.options != "" ~}
        options: ${partition.mount.options}
%{ endif ~}
%{ endif ~}
%{ endfor ~}
%{ for index, volume_group in lvm ~}
      - id: volgroup-${volume_group.name}
        type: lvm_volgroup
        name: ${volume_group.name}
        devices:
%{ for index, partition in partitions ~}
%{ if lookup(partition, "volume_group", "") == volume_group.name ~}
          - partition-${partition.name}
%{ endif ~}
%{ endfor ~}
%{ for index, partition in volume_group.partitions ~}
      - id: partition-${partition.name}
        type: lvm_partition
        name: ${partition.name}
        size: ${partition.size}M
        volgroup: volgroup-${volume_group.name}
      - id: format-${partition.name}
        type: format
        volume: partition-${partition.name}
        label: ${partition.format.label}
        fstype: ${partition.format.fstype}
      - id: mount-${partition.name}
        type: mount
%{ if partition.mount.path == "" ~}
        path: none
%{ else ~}
        path: ${partition.mount.path}
%{ endif ~}
        device: format-${partition.name}
%{ if partition.mount.options != "" ~}
        options: ${partition.mount.options}
%{ endif ~}
%{ endfor ~}
%{ endfor ~}
%{~ endif ~}