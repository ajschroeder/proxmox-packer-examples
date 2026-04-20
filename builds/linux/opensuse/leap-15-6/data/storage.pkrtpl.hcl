<partitioning t="list">
  %{ for disk in disks ~}
  <drive t="map">
    <device>/dev/${disk.device_name}</device>
    <disklabel>gpt</disklabel>
    <partitions t="list">
      %{ for p in partitions ~}
      %{ if p.disk_device == disk.device_name ~}
      <partition t="map">
        <create t="boolean">true</create>
        %{ if p.role == "pv" ~}
        <lvm_group>${p.vg}</lvm_group>
        <partition_id t="integer">142</partition_id>
        <format t="boolean">false</format>
        %{ else ~}
          %{ if p.role != "bios_grub" ~}
        <mount>${p.filesystem.mount}</mount>
        <format t="boolean">true</format>
        <mountby config:type="symbol">uuid</mountby>
        <filesystem config:type="symbol">${
          p.filesystem.fstype == "swap" ? "swap" :
          p.filesystem.fstype == "fat32" ? "vfat" :
          p.filesystem.fstype
        }</filesystem>
          %{ else ~}
        <format t="boolean">false</format>
          %{ endif ~}
        <partition_id t="integer">${
          p.role == "bios_grub" ? 259 :
          p.role == "efi" ? 259 :
          p.filesystem.fstype == "swap" ? 130 : 131
        }</partition_id>
        %{ endif ~}
        <size>${p.size == -1 ? "max" : "${p.size}M"}</size>
      </partition>
      %{ endif ~}
      %{ endfor ~}
    </partitions>
    <type t="symbol">CT_DISK</type>
    <use>all</use>
  </drive>
  %{ endfor ~}
  %{ for vg in volume_groups ~}
  <drive t="map">
    <device>/dev/${vg.name}</device>
    <enable_snapshots t="boolean">false</enable_snapshots>
    <partitions t="list">
      %{ for lv in logical_vols ~}
      %{ if lv.vg_name == vg.name ~}
      <partition t="map">
        <create t="boolean">true</create>
        <lv_name>${lv.name}</lv_name>
        <format t="boolean">true</format>
        <mountby t="symbol">device</mountby>
        <filesystem config:type="symbol">${lv.filesystem.fstype == "swap" ? "swap" : lv.filesystem.fstype}</filesystem>
        <mount>${lv.filesystem.fstype == "swap" ? "swap" : lv.filesystem.mount}</mount>
        <size>${lv.size == -1 ? "max" : "${lv.size}M"}</size>
        %{ if lv.filesystem.options != "" ~}
        <fstopt>${lv.filesystem.options}</fstopt>
        %{ endif ~}
        <stripes t="integer">1</stripes>
        <stripesize t="integer">0</stripesize>
      </partition>
      %{ endif ~}
      %{ endfor ~}
    </partitions>
    <pesize>4194304</pesize>
    <type t="symbol">CT_LVM</type>
  </drive>
  %{ endfor ~}
</partitioning>
