### Sets how the boot loader should be installed.
bootloader --location=mbr

### Initialize any invalid partition tables found on disks.
zerombr

### Removes partitions from the system, prior to creation of new partitions.
### By default, no partitions are removed.
### --all	Erases all partitions from the system
### --initlabel Initializes a disk (or disks) by creating a default disk label for all disks in their respective architecture.
clearpart --all --initlabel

### Modify partition sizes for the virtual machine hardware.
### Create primary system partitions.
%{ if length(partitions) == 1 && partitions[0].name == "autopart" ~}
     %{ if partitions[0].format.fstype == "lvm" ~}
autopart --type=lvm
     %{ endif }
     %{ if partitions[0].format.fstype == "simple" ~}
autopart --type=plain
     %{ endif }
     %{ if partitions[0].format.fstype == "" ~}
autopart --type=plain
     %{ endif }
%{ else }
     %{ for partition in partitions ~}
          %{ if partition.format.fstype == "swap" ~}
part swap --size=${partition.size}

          %{ endif ~}
          %{ if partition.mount.path == "/boot/efi" ~}
part ${partition.mount.path} --fstype vfat --size=${partition.size} --label=${partition.format.label}

          %{ endif ~}
          %{ if partition.mount.path != "" ~}
part ${partition.mount.path} --fstype ${partition.format.fstype} --size=${partition.size} --label=${partition.format.label} %{~ if partition.mount.options != "" ~}--fsoptions="${partition.mount.options}"%{~ endif ~}

          %{ endif ~}
          %{ if partition.volume_group != "" ~}
               %{ if partition.size == -1 ~}
part pv.${partition.volume_group} --size=100 --grow

               %{ else ~}
part pv.${partition.volume_group} --size=${partition.size}

               %{ endif ~}
### Create a logical volume management (LVM) group.
### Modify logical volume sizes for the virtual machine hardware.
               %{ for index, volume_group in lvm ~}
                    %{ if partition.volume_group != "" ~}
volgroup ${volume_group.name} --pesize=4096 pv.${partition.volume_group}

                    %{ endif ~}
### Create logical volumes.
                    %{ for partition in volume_group.partitions ~}
                         %{ if partition.format.fstype == "swap" ~}
logvol swap --fstype ${partition.format.fstype} --name=${partition.name} --vgname=${volume_group.name} --size=${partition.size} --label=${partition.format.label}
                         %{ else ~}
logvol ${partition.mount.path} %{ if partition.format.fstype == "fat32" } --fstype vfat %{ else } --fstype ${partition.format.fstype} %{ endif } %{ if partition.size != -1 } --size=${partition.size} %{ else } --size=100 --grow %{ endif } --name=${partition.name} --vgname=${volume_group.name} --label=${partition.format.label} %{ if partition.mount.options != "" ~} --fsoptions="${partition.mount.options}" %{~ endif ~}

                         %{ endif ~}
                    %{ endfor ~}
               %{ endfor ~}
          %{ endif ~}
     %{ endfor ~}
%{ endif }
