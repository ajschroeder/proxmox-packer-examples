  <partitioning t="list">
    <drive t="map">
      <device>/dev/${device}</device>
      <disklabel>gpt</disklabel>
      <partitions t="list">
%{ for index, partition in partitions ~}
        <partition t="map">
          <create t="boolean">true</create>
%{ if partition.volume_group != "" ~}
          <lvm_group>${partition.volume_group}</lvm_group>
          <partition_id t="integer">142</partition_id>
          <format t="boolean">false</format>
%{ else ~}
%{ if partition.format.fstype == "swap" ~}
          <filesystem config:type="symbol">swap</filesystem>
          <partition_id t="integer">130</partition_id>
          <format t="boolean">true</format>
%{ else ~}
          <label>${partition.format.label}</label>
          <resize t="boolean">false</resize>
          <mountby config:type="symbol">uuid</mountby>
%{ endif ~}
%{ if partition.format.fstype == "fat32" ~}
          <filesystem config:type="symbol">vfat</filesystem>
%{ if partition.mount.path == "/boot/efi" ~}
          <partition_id t="integer">259</partition_id>
          <fstopt>utf8</fstopt>
%{ else ~}
          <partition_id t="integer">12</partition_id>
%{ endif ~}
%{ else ~}
          <filesystem config:type="symbol">${partition.format.fstype}</filesystem>
          <partition_id t="integer">131</partition_id>
%{ endif ~}
          <format t="boolean">true</format>
          <mount>${partition.mount.path}</mount>
%{ endif ~}
%{ if partition.size != -1 ~}
          <size>${partition.size}M</size>
%{ else ~}
          <size>max</size>
%{ endif ~}
          <!--<partition_nr t="integer">${index}</partition_nr>-->
        </partition>
%{ endfor ~}
      </partitions>
      <type t="symbol">CT_DISK</type>
      <use>all</use>
    </drive>
%{ for index, volume_group in lvm ~}
    <drive t="map">
      <device>/dev/${volume_group.name}</device>
      <enable_snapshots t="boolean">false</enable_snapshots>
      <partitions t="list">
%{ for partition in volume_group.partitions ~}
        <partition t="map">
          <create t="boolean">true</create>
%{ if partition.format.fstype == "swap" ~}
          <filesystem config:type="symbol">swap</filesystem>
          <mount>swap</mount>
%{ else ~}
          <filesystem config:type="symbol">${partition.format.fstype}</filesystem>
          <mount>${partition.mount.path}</mount>
%{ endif ~}
          <lv_name>${partition.name}</lv_name>
          <format t="boolean">false</format>
          <mountby t="symbol">device</mountby>
          <pool t="boolean">false</pool>
          <resize t="boolean">false</resize>
%{ if partition.mount.options != "" ~}
         <fstopt>${partition.mount.options}</fstopt>
%{ endif ~}
%{ if partition.size != -1 ~}
          <size>${partition.size}M</size>
%{ else ~}
          <size>max</size>
%{ endif ~}
          <stripes t="integer">1</stripes>
          <stripesize t="integer">0</stripesize>
        </partition>
%{ endfor ~}
      </partitions>
      <pesize>4194304</pesize>
      <type t="symbol">CT_LVM</type>
    </drive>
%{ endfor ~}
  </partitioning>