d-i netcfg/choose_interface select ${device}
%{ if ip != null ~}
d-i netcfg/disable_autoconfig boolean true
d-i netcfg/get_ipaddress string ${ip}
d-i netcfg/get_netmask string ${cidrnetmask("${ip}/${netmask}")}
d-i netcfg/get_gateway string ${gateway}
d-i netcfg/get_nameservers string ${join(" ", dns)}
d-i netcfg/confirm_static boolean true
%{ endif ~}