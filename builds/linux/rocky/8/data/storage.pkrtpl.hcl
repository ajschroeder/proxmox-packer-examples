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
### Physical partitions
%{ for line in plan.partition_lines ~}
${line}
%{ endfor ~}

### Volume group
%{ if plan.lvm_enabled ~}
%{ for line in plan.volgroup_lines ~}
${line}
%{ endfor ~}
%{ endif ~}

### Logical volumes
%{ for line in plan.logvol_lines ~}
${line}
%{ endfor ~}
