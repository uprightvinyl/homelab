# uprightlab — dede Setup

This is a one off task to configure the 1TB second disk in dede so it can be used for VM storage.

```bash
ssh root@10.0.10.11
pvcreate /dev/sda
vgcreate mx500 /dev/sda
lvcreate --type thin-pool -l 100%FREE -n mx500 mx500
pvesm add lvmthin mx500 --vgname mx500 --thinpool mx500 --content images,rootdir --nodes dede
```