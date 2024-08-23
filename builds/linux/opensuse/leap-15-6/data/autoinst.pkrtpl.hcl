<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
  <add-on t="map">
    <add_on_others t="list">
      <listentry t="map">
        <alias>repo-backports-update</alias>
        <media_url>http://download.opensuse.org/update/leap/15.6/backports/</media_url>
        <name>Update repository of openSUSE Backports</name>
        <priority t="integer">99</priority>
        <product_dir>/</product_dir>
      </listentry>
      <listentry t="map">
        <alias>repo-non-oss</alias>
        <media_url>http://download.opensuse.org/distribution/leap/15.6/repo/non-oss/</media_url>
        <name>Non-OSS Repository</name>
        <priority t="integer">99</priority>
        <product_dir>/</product_dir>
      </listentry>
      <listentry t="map">
        <alias>repo-sle-update</alias>
        <media_url>http://download.opensuse.org/update/leap/15.6/sle/</media_url>
        <name>Update repository with updates from SUSE Linux Enterprise 15</name>
        <priority t="integer">99</priority>
        <product_dir>/</product_dir>
      </listentry>
      <listentry t="map">
        <alias>repo-update</alias>
        <media_url>http://download.opensuse.org/update/leap/15.6/oss</media_url>
        <name>Main Update Repository</name>
        <priority t="integer">99</priority>
        <product_dir>/</product_dir>
      </listentry>
      <listentry t="map">
        <alias>repo-update-non-oss</alias>
        <media_url>http://download.opensuse.org/update/leap/15.6/non-oss/</media_url>
        <name>Update Repository (Non-Oss)</name>
        <priority t="integer">99</priority>
        <product_dir>/</product_dir>
      </listentry>
    </add_on_others>
  </add-on>
  <bootloader t="map">
    <global t="map">
      <append>splash=silent preempt=full mitigations=auto quiet security=apparmor</append>
      <cpu_mitigations>auto</cpu_mitigations>
      <gfxmode>auto</gfxmode>
      <hiddenmenu>false</hiddenmenu>
      <os_prober>true</os_prober>
      <secure_boot>false</secure_boot>
      <terminal>gfxterm</terminal>
      <timeout t="integer">8</timeout>
      <trusted_grub>false</trusted_grub>
      <update_nvram>true</update_nvram>
      <xen_kernel_append>vga=gfx-1024x768x16</xen_kernel_append>
    </global>
  </bootloader>
  <kdump>
    <add_crash_kernel config:type="boolean">false</add_crash_kernel>
  </kdump>
  <firewall t="map">
    <default_zone>public</default_zone>
    <enable_firewall t="boolean">true</enable_firewall>
    <log_denied_packets>off</log_denied_packets>
    <start_firewall t="boolean">true</start_firewall>
    <zones t="list">
      <zone t="map">
        <description>Unsolicited incoming network packets are rejected. Incoming packets that are related to outgoing network connections are accepted. Outgoing network connections are allowed.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>block</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list"/>
        <short>Block</short>
        <target>%%REJECT%%</target>
      </zone>
      <zone t="map">
        <description>For computers in your demilitarized zone that are publicly-accessible with limited access to your internal network. Only selected incoming connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>dmz</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>ssh</service>
        </services>
        <short>DMZ</short>
        <target>default</target>
      </zone>
      <zone t="map">
        <description>All network connections are accepted.</description>
        <interfaces t="list">
          <interface>docker0</interface>
        </interfaces>
        <masquerade t="boolean">false</masquerade>
        <name>docker</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list"/>
        <short>docker</short>
        <target>ACCEPT</target>
      </zone>
      <zone t="map">
        <description>Unsolicited incoming network packets are dropped. Incoming packets that are related to outgoing network connections are accepted. Outgoing network connections are allowed.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>drop</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list"/>
        <short>Drop</short>
        <target>DROP</target>
      </zone>
      <zone t="map">
        <description>For use on external networks. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">true</masquerade>
        <name>external</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>ssh</service>
        </services>
        <short>External</short>
        <target>default</target>
      </zone>
      <zone t="map">
        <description>For use in home areas. You mostly trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>home</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>dhcpv6-client</service>
          <service>mdns</service>
          <service>samba-client</service>
          <service>ssh</service>
        </services>
        <short>Home</short>
        <target>default</target>
      </zone>
      <zone t="map">
        <description>For use on internal networks. You mostly trust the other computers on the networks to not harm your computer. Only selected incoming connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>internal</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>dhcpv6-client</service>
          <service>mdns</service>
          <service>samba-client</service>
          <service>ssh</service>
        </services>
        <short>Internal</short>
        <target>default</target>
      </zone>
      <zone t="map">
        <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
        <interfaces t="list">
          <interface>eth0</interface>
        </interfaces>
        <masquerade t="boolean">false</masquerade>
        <name>public</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>dhcpv6-client</service>
          <service>ssh</service>
        </services>
        <short>Public</short>
        <target>default</target>
      </zone>
      <zone t="map">
        <description>All network connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>trusted</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list"/>
        <short>Trusted</short>
        <target>ACCEPT</target>
      </zone>
      <zone t="map">
        <description>For use in work areas. You mostly trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
        <interfaces t="list"/>
        <masquerade t="boolean">false</masquerade>
        <name>work</name>
        <ports t="list"/>
        <protocols t="list"/>
        <services t="list">
          <service>dhcpv6-client</service>
          <service>ssh</service>
        </services>
        <short>Work</short>
        <target>default</target>
      </zone>
    </zones>
  </firewall>
  <general t="map">
    <mode t="map">
      <confirm t="boolean">false</confirm>
    </mode>
  </general>
  <groups t="list">
    <group t="map">
      <gid>100</gid>
      <groupname>users</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>493</gid>
      <groupname>utmp</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>65533</gid>
      <groupname>nogroup</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>71</gid>
      <groupname>ntadmin</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>488</gid>
      <groupname>input</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>491</gid>
      <groupname>cdrom</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>475</gid>
      <groupname>polkitd</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>1</gid>
      <groupname>bin</groupname>
      <userlist>daemon</userlist>
    </group>
    <group t="map">
      <gid>2</gid>
      <groupname>daemon</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>65534</gid>
      <groupname>nobody</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>36</gid>
      <groupname>kvm</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>59</gid>
      <groupname>maildrop</groupname>
      <userlist>postfix</userlist>
    </group>
    <group t="map">
      <gid>477</gid>
      <groupname>sshd</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>482</gid>
      <groupname>chrony</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>489</gid>
      <groupname>disk</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>492</gid>
      <groupname>audio</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>494</gid>
      <groupname>lock</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>15</gid>
      <groupname>shadow</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>485</gid>
      <groupname>tape</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>495</gid>
      <groupname>kmem</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>5</gid>
      <groupname>tty</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>480</gid>
      <groupname>systemd-network</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>484</gid>
      <groupname>video</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>499</gid>
      <groupname>messagebus</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>486</gid>
      <groupname>sgx</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>497</gid>
      <groupname>lp</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>487</gid>
      <groupname>render</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>0</gid>
      <groupname>root</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>42</gid>
      <groupname>trusted</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>479</gid>
      <groupname>systemd-timesync</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>481</gid>
      <groupname>systemd-journal</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>51</gid>
      <groupname>postfix</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>490</gid>
      <groupname>dialout</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>483</gid>
      <groupname>audit</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>498</gid>
      <groupname>mail</groupname>
      <userlist>postfix</userlist>
    </group>
    <group t="map">
      <gid>62</gid>
      <groupname>man</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>496</gid>
      <groupname>wheel</groupname>
      <userlist/>
    </group>
    <group t="map">
      <gid>478</gid>
      <groupname>nscd</groupname>
      <userlist/>
    </group>
  </groups>
  <host t="map">
    <hosts t="list">
      <hosts_entry t="map">
        <host_address>127.0.0.1</host_address>
        <names t="list">
          <name>localhost</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>::1</host_address>
        <names t="list">
          <name>localhost ipv6-localhost ipv6-loopback</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>fe00::0</host_address>
        <names t="list">
          <name>ipv6-localnet</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>ff00::0</host_address>
        <names t="list">
          <name>ipv6-mcastprefix</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>ff02::1</host_address>
        <names t="list">
          <name>ipv6-allnodes</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>ff02::2</host_address>
        <names t="list">
          <name>ipv6-allrouters</name>
        </names>
      </hosts_entry>
      <hosts_entry t="map">
        <host_address>ff02::3</host_address>
        <names t="list">
          <name>ipv6-allhosts</name>
        </names>
      </hosts_entry>
    </hosts>
  </host>
  <networking t="map">
    <dhcp_options t="map">
      <dhclient_client_id/>
      <dhclient_hostname_option>AUTO</dhclient_hostname_option>
    </dhcp_options>
    <dns t="map">
      <dhcp_hostname t="boolean">true</dhcp_hostname>
      <hostname>localhost</hostname>
      <resolv_conf_policy>auto</resolv_conf_policy>
    </dns>
    <interfaces t="list">
      <interface t="map">
        <bootproto>dhcp</bootproto>
        <name>eth0</name>
        <startmode>auto</startmode>
        <zone>public</zone>
      </interface>
    </interfaces>
    <ipv6 t="boolean">true</ipv6>
    <keep_install_network t="boolean">true</keep_install_network>
    <managed t="boolean">false</managed>
    <routing t="map">
      <ipv4_forward t="boolean">false</ipv4_forward>
      <ipv6_forward t="boolean">false</ipv6_forward>
    </routing>
  </networking>
  <ntp-client t="map">
    <ntp_policy>auto</ntp_policy>
    <ntp_servers t="list"/>
    <ntp_sync>systemd</ntp_sync>
  </ntp-client>
${storage}
  <proxy t="map">
    <enabled t="boolean">false</enabled>
  </proxy>
  <services-manager t="map">
    <default_target>multi-user</default_target>
    <services t="map">
      <enable t="list">
        <service>YaST2-Firstboot</service>
        <service>YaST2-Second-Stage</service>
        <service>apparmor</service>
        <service>auditd</service>
        <service>klog</service>
        <service>chronyd</service>
        <service>cron</service>
        <service>cups</service>
        <service>firewalld</service>
        <service>wickedd-auto4</service>
        <service>wickedd-dhcp4</service>
        <service>wickedd-dhcp6</service>
        <service>wickedd-nanny</service>
        <service>irqbalance</service>
        <service>issue-generator</service>
        <service>kbdsettings</service>
        <service>lvm2-monitor</service>
        <service>mcelog</service>
        <service>wicked</service>
        <service>nscd</service>
        <service>postfix</service>
        <service>purge-kernels</service>
        <service>rsyslog</service>
        <service>smartd</service>
        <service>sshd</service>
        <service>systemd-fsck-root</service>
        <service>systemd-pstore</service>
        <service>systemd-remount-fs</service>
        <service>qemu-guest-agent</service>
      </enable>
    </services>
  </services-manager>
  <software t="map">
    <install_recommended t="boolean">true</install_recommended>
    <instsource/>
    <packages t="list">
      <package>wicked</package>
      <package>os-prober</package>
      <package>openssh</package>
      <package>openSUSE-release</package>
      <package>lvm2</package>
      <package>kexec-tools</package>
      <package>grub2</package>
      <package>glibc</package>
      <package>firewalld</package>
      <package>e2fsprogs</package>
      <package>chrony</package>
      <package>autoyast2</package>
      <package>qemu-guest-agent</package>
    </packages>
    <patterns t="list">
      <pattern>apparmor</pattern>
      <pattern>base</pattern>
      <pattern>documentation</pattern>
      <pattern>enhanced_base</pattern>
      <pattern>minimal_base</pattern>
      <pattern>sw_management</pattern>
      <pattern>yast2_basis</pattern>
    </patterns>
    <products t="list">
      <product>Leap</product>
    </products>
  </software>
  <ssh_import t="map">
    <copy_config t="boolean">false</copy_config>
    <import t="boolean">false</import>
  </ssh_import>
  <timezone t="map">
    <timezone>${vm_os_timezone}</timezone>
  </timezone>
  <user_defaults t="map">
    <expire/>
    <group>100</group>
    <home>/home</home>
    <inactive>-1</inactive>
    <shell>/bin/bash</shell>
    <umask>022</umask>
  </user_defaults>
  <users t="list">
    <user t="map">
      <authorized_keys t="list"/>
      <encrypted t="boolean">true</encrypted>
      <fullname>Build User</fullname>
      <gid>100</gid>
      <home>/home/${build_username}</home>
      <home_btrfs_subvolume t="boolean">false</home_btrfs_subvolume>
      <password_settings t="map">
        <expire/>
        <flag/>
        <inact/>
        <max>99999</max>
        <min>0</min>
        <warn>7</warn>
      </password_settings>
      <shell>/bin/bash</shell>
      <uid>1000</uid>
      <user_password>${build_password_encrypted}</user_password>
      <username>${build_username}</username>
    </user>
  </users>
  <scripts>
    <post-scripts config:type="list">
      <script>
        <filename>post.sh</filename>
        <interpreter>shell</interpreter>
        <feedback config:type="boolean">false</feedback>
        <source><![CDATA[
          #!/bin/sh
          usermod -aG wheel ${build_username}
          echo '${build_username} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/${build_username}
          sed -i '/NOPASSWD/s/^# //g' /etc/sudoers
          ]]>
        </source>
      </script>
    </post-scripts>
    <init-scripts config:type="list">
      <script>
        <source><![CDATA[
          #!/bin/sh
          systemctl enable --now qemu-guest-agent
          ]]>
        </source>
      </script>
    </init-scripts>
  </scripts>
</profile>
