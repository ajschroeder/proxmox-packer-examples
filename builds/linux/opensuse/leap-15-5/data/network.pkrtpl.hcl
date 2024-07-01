  <networking t="map">
    <dhcp_options t="map">
      <dhclient_client_id/>
      <dhclient_hostname_option>AUTO</dhclient_hostname_option>
    </dhcp_options>
    <dns t="map">
%{ if ip != null ~}
      <nameservers config:type="list">
%{ for dns_server in dns ~}
        <nameserver>${dns_server}</nameserver>
%{ endfor ~}
      </nameservers>
%{ else ~}
      <dhcp_hostname t="boolean">true</dhcp_hostname>
      <hostname>localhost</hostname>
%{ endif ~}
      <resolv_conf_policy>auto</resolv_conf_policy>
    </dns>
    <interfaces t="list">
      <interface t="map">
%{ if ip != null ~}
        <bootproto>static</bootproto>
        <ipaddr>${ip}</ipaddr>
        <prefixlen>${netmask}</prefixlen>
%{ else ~}
        <bootproto>dhcp</bootproto>
%{ endif ~}
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
%{ if ip != null ~}
      <routes t="list">
        <route t="map">
          <destination>default</destination>
          <device>-</device>
          <gateway>${gateway}</gateway>
          <netmask>-</netmask>
        </route>
      </routes>
%{ endif ~}
    </routing>
  </networking>