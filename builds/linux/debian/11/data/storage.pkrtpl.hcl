
%{~ if length(lvm) != 0 ~}
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
    %{~ for volume_group in lvm ~}
d-i partman-auto-lvm/new_vg_name string ${volume_group.name}
    %{~ endfor ~}
%{~ endif ~}

d-i partman-efi/non_efi_system boolean true

# Ensure the partition table is GPT - this is required for EFI
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt

# If there is only one partition defined and its name is 'autopart'
# then use auto partitioning
%{~ if length(partitions) == 1 && partitions[0].name == "autopart" ~}
d-i partman-auto/disk string /dev/${device}
    %{~ if partitions[0].format.fstype == "lvm" ~}
d-i partman-auto/method string lvm

# You can define the amount of space that will be used for the LVM volume
# group. It can either be a size with its unit (eg. 20 GB), a percentage of
# free space or the 'max' keyword.
d-i partman-auto-lvm/guided_size string max

# If one of the disks that are going to be automatically partitioned
# contains an old LVM configuration, the user will normally receive a
# warning. This can be preseeded away...
d-i partman-lvm/device_remove_lvm boolean true
# And the same goes for the confirmation to write the lvm partitions.
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

    %{~ endif ~}
    %{~ if partitions[0].format.fstype == "simple" ~}
d-i partman-auto/method string regular
    %{~ endif ~}
    %{ if partitions[0].format.fstype == "" ~}
d-i partman-auto/method string regular
    %{~ endif ~}
# You can choose one of the three predefined partitioning recipes:
# - atomic: all files in one partition
# - home:   separate /home partition
# - multi:  separate /home, /var, and /tmp partitions
d-i partman-auto/choose_recipe select atomic

%{~ else ~} # if length(partitions) == 1 && partitions[0].name == "autopart"
    %{~ if swap == false ~}
d-i partman-basicfilesystems/no_swap boolean false
    %{~ endif ~}
d-i partman-auto/expert_recipe string \
  custom :: \
    %{~ for partition in partitions ~}
        %{~ if lookup(partition, "volume_group", "") == "" ~}
            %{~ if partition.size != -1 ~}
    ${partition.size} ${partition.size} ${partition.size} ${partition.format.fstype} \
            %{~ else ~}
    100 100 -1 ${partition.format.fstype} \
            %{~ endif ~}
    $primary{ } \
            %{~ if partition.mount.path == "/boot" ~}
    $bootable{ } \
    mountpoint{ /boot } \
    method{ format } \
            %{~ endif ~}
            %{~ if partition.mount.path == "/boot/efi" ~}
    mountpoint{ /boot/efi } \
    method{ efi } \
            %{~ endif ~}
            %{~ if partition.mount.path != "/boot" && partition.mount.path != "/boot/efi" ~}
                %{~ if partition.mount.path != "" ~}
    mountpoint{ ${partition.mount.path} } \
                %{~ endif ~}
    method{ ${partition.format.fstype} } \
            %{~ endif ~}
    format{ } \
            %{~ if partition.format.fstype != "swap" ~}
    use_filesystem{ } \
                %{~ if partition.format.fstype == "fat32" ~}
    filesystem{ vfat } \
                %{~ else ~}
    filesystem{ ${partition.format.fstype} } \
                %{~ endif ~}
            %{~ endif ~}
    label { ${partition.format.label} } \
            %{~ for option in split(",", lookup(partition.mount, "options", "")) ~}
                %{~ if option != "" ~}
    options/${option}{ ${option} } \
                %{~ endif ~}
            %{~ endfor ~}           
    . \
        %{~ else /* if lookup(partition, "volume_group", "") == "" */ ~}
            %{~ for volume_group in lvm ~}
                %{~ if volume_group.name == partition.volume_group ~}
                    %{~ for partition in volume_group.partitions ~}
                        %{ if partition.size != -1 ~}
                            %{ if partition.format.fstype == "swap" ~}
    ${partition.size} ${partition.size} ${partition.size} linux-swap \
                            %{~ else ~}
    ${partition.size} ${partition.size} ${partition.size} ${partition.format.fstype} \
                            %{~ endif ~}
                        %{~ else ~}
                            %{~ if partition.format.fstype != "swap" /* I don't know who would fill their disk with swap but it could happen */ ~}
    100 100 -1 ${partition.format.fstype} \
                            %{~ else ~}
    100 100 -1 linux-swap \
                            %{~ endif ~}
                        %{ endif ~}
    $lvmok{ } \
                        %{~ if partition.mount.path != "" ~}
    mountpoint{ ${partition.mount.path} } \
                        %{~ endif ~}
    lv_name{ ${partition.name} } \
    in_vg { ${volume_group.name} } \
                        %{~ if partition.format.fstype == "swap" ~}
    method{ swap } \
                        %{~ else ~}
    method{ format } \
                        %{~ endif ~}
    format{ } \
                        %{~ if partition.format.fstype != "swap" ~}
    use_filesystem{ } \
    filesystem{ ${partition.format.fstype} } \
                        %{~ endif ~}
    label { ${partition.format.label} } \
                        %{~ for option in split(",", lookup(partition.mount, "options", "")) ~}
                            %{~ if option != "" ~}
    options/${option}{ ${option} } \
                            %{~ endif ~}
                        %{~ endfor ~}
    . \
                    %{~ endfor /* partition in volume_group.partitions */ ~}
    1024 1024 1024 ext4 \
    method{ lvm } \
    $lvmok{ } \
    lv_name{ lv_delete } \
    mountpoint{ /tmp/lv_delete } \
    . \
                %{~ endif /* volume_group.name == partition.volume_group */ ~} 
            %{~ endfor /* for volume_group in lvm */ ~}
        %{~ endif /* if lookup(partition, "volume_group", "") == "" */ ~}
    %{~ endfor /* for partition in partitions */ ~}

%{~ endif /* if length(partitions) == 1 && partitions[0].name == "autopart" */ ~}

d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# To make sure the machine can boot we install grub on the first harddisk:
d-i grub-installer/bootdev string /dev/${device}