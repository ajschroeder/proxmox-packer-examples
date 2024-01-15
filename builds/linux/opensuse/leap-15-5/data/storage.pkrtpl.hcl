  <partitioning t="list">
    <drive t="map">
      <device>/dev/system</device>
      <enable_snapshots t="boolean">false</enable_snapshots>
      <partitions t="list">
        <partition t="map">
          <create t="boolean">true</create>
          <filesystem t="symbol">ext4</filesystem>
          <format t="boolean">false</format>
          <lv_name>root</lv_name>
          <mount>/</mount>
          <mountby t="symbol">device</mountby>
          <pool t="boolean">false</pool>
          <resize t="boolean">false</resize>
          <size>32199671808</size>
          <!--<size>max</size>-->
          <stripes t="integer">1</stripes>
          <stripesize t="integer">0</stripesize>
        </partition>
        <partition t="map">
          <create t="boolean">true</create>
          <filesystem t="symbol">swap</filesystem>
          <format t="boolean">false</format>
          <lv_name>swap</lv_name>
          <mount>swap</mount>
          <mountby t="symbol">device</mountby>
          <pool t="boolean">false</pool>
          <resize t="boolean">false</resize>
          <size>2147483648</size>
          <!--<size>auto</size>-->
          <stripes t="integer">1</stripes>
          <stripesize t="integer">0</stripesize>
        </partition>
      </partitions>
      <pesize>4194304</pesize>
      <type t="symbol">CT_LVM</type>
    </drive>
    <drive t="map">
      <device>/dev/${device}</device>
      <disklabel>gpt</disklabel>
      <partitions t="list">
        <partition t="map">
          <create t="boolean">true</create>
          <format t="boolean">false</format>
          <partition_id t="integer">263</partition_id>
          <partition_nr t="integer">1</partition_nr>
          <resize t="boolean">false</resize>
          <size>8388608</size>
        </partition>
        <partition t="map">
          <create t="boolean">true</create>
          <format t="boolean">false</format>
          <lvm_group>system</lvm_group>
          <partition_id t="integer">142</partition_id>
          <partition_nr t="integer">2</partition_nr>
          <resize t="boolean">false</resize>
          <size>34350284288</size>
        </partition>
      </partitions>
      <type t="symbol">CT_DISK</type>
      <use>all</use>
    </drive>
  </partitioning>