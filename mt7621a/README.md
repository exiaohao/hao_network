## 小米路由器R3G MT7621A 折腾记录

2018.10 购入 💰 199
准备工具: 一块优盘，一只📎

### 进入开发者模式

- 去 http://www.miwifi.com/miwifi_download.html 下载最新的 R3G 开发版, 更新系统到开发版本;
- 用手机 APP 绑定小米路由器到你的小米账号, 使用路由器打开 https://d.miwifi.com/rom/ssh 放弃保修并**获取 root 密码**, 下载 `minifi_ssh.bin`, 拷入 FAT/FAT32 格式化后的优盘; 重启路由器 📎捅屁屁到闪。此操作官方有说。
- 优盘装入 breed (可选, 回头 scp 传入也可)

### 登录 SSH 权限和基本操作
```bash
ssh root@192.168.31.1
```
输入密码后, 先做一些基本操作:

```bash
nvram set boot_wait=on
nvram set uart_en=1      // 启用串口, 默认是没有启用的. 如果玩成了砖又没起串口…
nvram commit
```

备份路由器原始信息
```bash
# cat /proc/mtd
```
可以看到现在的分区信息, 需要备份 0 - 13, 14 因为当前在使用所以备份不了, 能把系统捞回来配置丢了也无所谓了. 用刚才写 `minifi_ssh.bin` 的优盘接收一下备份:
```bash
dd if=/dev/mtd0 of=/extdisks/sda1/backup/ALL.bin
dd if=/dev/mtd1 of=/extdisks/sda1/backup/Bootloader.bin
dd if=/dev/mtd2 of=/extdisks/sda1/backup/Config.bin
dd if=/dev/mtd3 of=/extdisks/sda1/backup/Bdata.bin
dd if=/dev/mtd4 of=/extdisks/sda1/backup/Factory.bin
dd if=/dev/mtd5 of=/extdisks/sda1/backup/crash.bin
dd if=/dev/mtd6 of=/extdisks/sda1/backup/crash_syslog.bin
dd if=/dev/mtd7 of=/extdisks/sda1/backup/reserved0.bin
dd if=/dev/mtd8 of=/extdisks/sda1/backup/kernel0.bin
dd if=/dev/mtd9 of=/extdisks/sda1/backup/kernel1.bin
dd if=/dev/mtd10 of=/extdisks/sda1/backup/rootfs0.bin
dd if=/dev/mtd11 of=/extdisks/sda1/backup/rootfs1.bin
dd if=/dev/mtd12 of=/extdisks/sda1/backup/overlay.bin
dd if=/dev/mtd13 of=/extdisks/sda1/backup/ubi_rootfs.bin
dd if=/dev/mtd14 of=/extdisks/sda1/backup/data.bin
```

⚠️  注意优盘盘符是什么, 不一定是 `sda1`

### 写 Breed 关键时刻救命, 需要时随时换 ROM
```bash
mtd -r write /extdisks/sda1/breed/breed.bin Bootloader
```

成功后, 重启路由器, 回形针怼 pp, 等到橙色灯闪烁松开, 检查DHCP地址, 能打开 http://192.168.1.1 就可以看到 Breed 控制台了
