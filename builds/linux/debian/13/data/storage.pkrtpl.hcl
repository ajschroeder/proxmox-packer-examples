# --- Disk & GPT ---
d-i partman-auto/disk string /dev/${plan.device}

# Choose partition recipe
d-i partman-auto/choose_recipe select mypartitioning

%{~ if length(plan.volume_groups) > 0 ~}
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
%{ for vg in plan.volume_groups ~}
d-i partman-auto-lvm/new_vg_name string ${vg}
%{ endfor ~}
%{~ else ~}
d-i partman-auto/method string regular
%{~ endif ~}

# Ensure the partition table is GPT - this is required for EFI
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt

%{~ if plan.firmware == "seabios" ~}
d-i grub-installer/bootdev string /dev/${plan.device}
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean false
%{~ endif ~}

d-i partman-auto/expert_recipe string \
  mypartitioning :: \
# --- Physical partitions ---
%{ for p in plan.partitions ~}
${p.size != -1 ? p.size : "100"} ${p.size != -1 ? p.size : "100"} ${p.size} \
  $primary{ } \
%{ if p.role == "efi" && plan.firmware == "ovmf" ~}
  method{ efi } \
  format{ } \
  use_filesystem{ } \
  filesystem{ vfat } \
  mountpoint{ ${p.filesystem.mount} } \
  label{ ${p.filesystem.label} } \
  . \
%{ else ~}
  %{~ if p.role == "bios_grub" && plan.firmware == "seabios" ~}
  method{ biosgrub } \
  device{ /dev/${plan.device} } \
  . \
  %{~ else ~}
    %{~ if p.role == "pv" ~}
  method{ lvm } \
  device{ /dev/${plan.device} } \
  vg_name{ ${p.vg_name} } \
  . \
    %{~ else ~}
      %{~ if p.role == "swap" ~}
  method{ swap } \
  format{ } \
  . \
      %{~ else ~}
  method{ format } \
  format{ } \
  use_filesystem{ } \
  filesystem{ ${p.filesystem.fstype} } \
        %{~ if p.filesystem.mount != "" ~}
  mountpoint{ ${p.filesystem.mount} } \
        %{~ endif ~}
        %{~ if p.filesystem.label != "" ~}
  label{ ${p.filesystem.label} } \
        %{~ endif ~}
  . \
      %{~ endif ~}
    %{~ endif ~}
  %{~ endif ~}
%{~ endif ~}
%{~ endfor ~}

# --- Logical volumes ---
%{ for lv in plan.logical_volumes ~}
%{ if lv.filesystem.fstype == "swap" ~}
${lv.size} ${lv.size} ${lv.size} linux-swap \
  $lvmok{ } \
  in_vg{ ${lv.vg_name} } \
  lv_name{ ${lv.name} } \
  method{ swap } \
  format{ } \
  . \
%{ else ~}
${lv.size} ${lv.size} ${lv.size} ${lv.filesystem.fstype} \
  $lvmok{ } \
  in_vg{ ${lv.vg_name} } \
  lv_name{ ${lv.name} } \
  method{ format } \
  format{ } \
  use_filesystem{ } \
  filesystem{ ${lv.filesystem.fstype} } \
%{ if lv.filesystem.mount != "" ~}
  mountpoint{ ${lv.filesystem.mount} } \
%{ endif ~}
%{ if lv.filesystem.label!= "" ~}
  label{ ${lv.filesystem.label} } \
%{ endif ~}
  . \
%{ endif ~}
%{ endfor ~}

# --- Confirmation ---
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

