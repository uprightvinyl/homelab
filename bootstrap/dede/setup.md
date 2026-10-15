# uprightlab — dede Setup

This is a one off task to configure the 256GB Micron second disk in dede so it can be used for VM storage.

```bash
ssh root@10.0.10.11
pvcreate /dev/sda
vgcreate vmdata /dev/sda
lvcreate --type thin-pool -l 100%FREE -n vmdata vmdata
pvesm add lvmthin vmdata --vgname vmdata --thinpool vmdata --content images,rootdir --nodes dede
```