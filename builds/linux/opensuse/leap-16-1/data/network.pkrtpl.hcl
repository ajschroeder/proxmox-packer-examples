%{ if ip != null ~}
${jsonencode({
  connections = [
    merge(
      {
        id          = device
        interface   = device
        method4     = "manual"
        method6     = "disabled"
        addresses   = ["${ip}/${netmask}"]
        autoconnect = true
        persistent  = true
      },
      gateway != null && gateway != "" ? { gateway4 = gateway } : {},
      length(dns) > 0 ? { nameservers = dns } : {}
    )
  ]
})}
%{ else ~}
${jsonencode({
  connections = [
    {
      id          = device
      interface   = device
      method4     = "auto"
      autoconnect = true
      persistent  = true
    }
  ]
})}
%{ endif ~}
