Setting up a recursive bind mount:
```shell
sudo mount -R -r / /home/vagrant/mycontainer/rootfs/
```
Unmounting the recurive bind mount:
```shell
sudo mount --make-rprivate /home/vagrant/mycontainer/rootfs/
sudo umount -R /home/vagrant/mycontainer/rootfs
```
