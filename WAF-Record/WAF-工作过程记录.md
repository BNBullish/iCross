前言：全文现象属实，分析部分纯属一个小白的个人观点，请带着批判的眼光参阅。



## 开机现象

详细记录参见[WAF-SETUP-LOG](./WAF-SETUP-LOG.txt)，这里截取部分

```
insmod: error inserting '/lib/sSCSI subsystem initialized
ha256_generic.ko': -1 File exists
insmod: error inserting '/lib/dm-region-hash.ko': -1 File exists
Waiting for driver initialization.
stabilized: open /proc/scsi/scsi: No such file or directory
Scanning and configuring dmraid supported devices
Loading /lib/kbd/keymaps/i386/qwerty/us.map
Can't open device: /dev/sda2
Command failed: No key available with this passphrase.

Scanning logical volumes
Activating logical volumes
  Volume group "vg_main" not found
  Volume group "vg_sda1" not found
Can't open device: /dev/mapper/vg_main-lv_root
Command failed: No key available with this passphrase.

Creating root device.
Mounting root filesystem.
mount: could not find filesystem '/dev/root'
Setting up other filesystems.
Setting up new root fs
```

## 分析与猜想

1. 可以看到	`No key available with this passphrase.`出现了两次，对比编译环境的虚拟机也是有两次解密过程。若CF卡上的镜像只加密了一个根分区，不应该出现两次解密过程。
2. 会不会是编译环境生成的用于解密的Key与CF卡需要的Key不一致，导致出现密钥不可用的提示。换句话说就是key-file是错误的。
3. 可以看到第二次解密过程中提示`vg_main`无法找到，而第一次解密中`/dev/sda2`没有这条提示。
4. 若以上猜测正确，则说明生成`initrd`文件的编译环境与实际CF卡环境有出入——一个是加密分区个数，另一个是`/dev/sda2`的解密密钥。
5. 若以上猜想正确，开机过程在`initrd`这步卡住，则说明内核加载过程已经通过，内核配置无误。当然不排除因为加载内核阶段出错导致的`initrd`阶段矛盾爆发。
6. 可是同一个镜像可以在之前的机器上开机又说明镜像是没问题的，说明以上假设不成立。

## 探索尝试

1. Centos 6.8——U盘做安装盘，在CF卡上安装系统

   不管是启动盘还是系统盘，U盘还是CF卡，都无法在目标机器上正常开机启动。

2. Centos 7 1511——U盘和CF卡作系统盘

   两者通过USB连接到目标主机都可以正常开机，可以输入分区解密口令。甚至插上网线可以联网。

   CF卡直接插在卡槽里会进入紧急模式。

   同样的CF卡换了连接方式就会表现不一样，是CF卡本身有问题，还是硬件与内核不搭配导致的？

3. 厂商提供的Debian镜像可以正常开机。

4. 观察可以开机的系统镜像都发现发现其内核配置中`CARDBUS=y`，不能开机的镜像中都没有这个配置

   而这个推论与分析(5)矛盾。

## 进一步分析

1. 原镜像似乎是采用LVM分区的。

2. 现在CF卡使用的镜像文件对于我可见的部分只是`/boot`分区，数据根分区是加密直接不可见的。

   操作的内容也只是`/boot`分区。

3. 与`/sda2`分区有直接关系的文件是`initrd`，这个文件除了加载模块之外，还要解密分区并挂载。

4. 指定了`key-file`当然不会出现要求输入分区解密口令这一步。

5. 在之前H61镜像的基础上，修改`initrd`中的解密`sda2`语句为不指定密钥文件。以下现象在之前出现过。

   这时开机后会提示输入解密口令，但是键盘毫无反应，无法输入任何字符，惠普和戴尔的键盘都不可以。

   而之前在`grub`阶段键盘是可以正常工作的。

   怀疑解密操作之前的`loadkeys -u us.map`语句有问题。删除之后问题依旧。

6. Google搜索 `luks keyboard not work` 得到以下链接或许有帮助，问题指向了内核模块在`initrd`阶段导入的操作

   ```
   https://www.linuxquestions.org/questions/slackware-14/non-working-usb-keyboard-at-luks-prompt-14-1-a-4175484332/

   ```

7. 尝试将CF卡通过USB接口启动，在`grub`阶段之后不久，CF卡的转接器灯灭掉，同样键盘无反应，启动停留在要求输入密码阶段。从转接器的灯灭掉可以推测此时USB已经不能供电不能工作。

8. 尝试重新编译内核添加USB相关模块，若配置为模块则需将该模块复制到`initrd`中的`lib`目录下，并在`init`中声明导入该模块。

9. 突然想到，USB工作与否跟能否正常开机启动无太大关系，前提是能够指定正确的`key-file`。由上面猜想分析(2)可知`key-file`有错误的可能。



## 附录

### 常用命令

1. 挂载

   ```
   mount -o loop,offset=32256 WAF-CASWELL-H61-Ker2.6.39.4-Ver20170426.img /mnt/
   ```

2. 解压`initrd`并重新打包

   ```
   mv map.img map.img.gz
   gunzip map.img.gz
   mkdir initrd && cd initrd
   cpio -ivmd < ../waf.img
   # 修改
   find . | cpio -o -H newc | gzip > ../initrd-new.img
   ```

3. ​