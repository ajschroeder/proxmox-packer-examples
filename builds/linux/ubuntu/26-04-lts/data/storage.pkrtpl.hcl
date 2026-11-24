%{ for d in plan.disk_lines ~}${d}
%{ endfor ~}
%{ for p in plan.partition_lines ~}${p}
%{ endfor ~}
%{ if plan.lvm_enabled ~}
%{ for vg in plan.volgroup_lines ~}${vg}
%{ endfor ~}
%{ for lv in plan.logvol_lines ~}${lv}
%{ endfor ~}
%{ endif ~}
