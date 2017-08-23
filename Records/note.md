### 交叉编译器命名

arch-vendor-kernel-system

---------------------------

### 源码编译安装流程

- ./configure –help 可以查看到，当前软件，支持哪些详细的功能和配置

- ./configure 

  --prefix=YOUR_INSTALL_PATH	将你的程序，安装到哪里，

  –build=CURRENT_ENV	i686-pc-linux-gnu 

  –target=CROSS_COMPILER和–host=CROSS_COMPILER 设置的是交叉编译器的（前缀）

  CC=CROSS_COMPILER-gcc	1.此处的CC参数，是用于指定编译器用哪个。一般都是对应的交叉编译器的前缀，加上gcc

- make

- make install

----------------------------

### 压缩相关

- tar -xvf xxx.tar.gz
- tar -xvjf xxx.tar.bz2
- **lzcat** is equivalent to **xz --format=lzma --decompress --stdout**

-------

### 文件夹介绍

```note
1. crosstool-ng-1.23.0
crosstool-ng的源码包：解压后的文件夹
包含了crosstool-ng的相关源码

2. crosstool-ng-1.23.0_build
专门为后期使用crosstool-ng去建立交叉编译器，的编译（build），而专门建立的文件夹
对应的，后续的ct-ng menuconfig，ct-ng build等命令，都是在此文件夹下执行的。

3. src
为crosstool-ng中，后续需要下载各种软件的源码包，而准备的，
crosstool-ng中，在开始执行build之后，会去下载对应的源码包，都会存放到这个文件夹下

4. x-tools
这个文件夹是用crosstool-ng所生成的交叉编译器，所在的路径。
对应的配置中，会有，类似于：
(${HOME}/develop/crosstool-ng/x-tools/${CT_TARGET}) Prefix directory
的配置，用来指定生成的交叉编译器，存放在何处。
此时，就是去设置为此处对应的路径即可。

5. crosstool-ng-1.23.0.tar.bz2
很明显，这个就是之前我在折腾crosstool-ng-1.18.0时，去下载的源码包了。
对应的上面的1，就是此源码包解压后的路径。
```

---

### 避免SSH连接自动结束

设置服务器 `/etc/ssh/sshd_config` 中 `ClientAliveInterval 60`

---

### 查看各版本号

OS: cat /etc/redhat-release

Kernel : cat /proc/version

glibc: rpm -qi glibc

gcc: cat /proc/version

### 查看支持的glibc版本

strings /usr/lib64/libc.so.6 | grep GLIBC

*注意* ：

- Debian系需要安装 binutils 才可以使用 strings


- Ubuntu较老的版本可以从ustc去设置源，ubuntu-old-releases

---

### Centos 6 mini 开启网络

修改配置文件 `/etc/sysconfig/network-script/ifcfg-eth0`        

```
NM_CONTROLLED="no" 
ONBOOT="yes"
BOOTPROTO="dhcp"
TYPE="Ethernet"
```

### Centos 7 32bit 没有网络设备问题

 由于Vmware虚拟网卡和linux兼容问题导致驱动无法正常安装，默认的网卡类型不兼容

找到我们的Vmware虚拟机文件夹，将VMware 虚拟机配置 (.vmx)，追加一条设置我们网卡类型ethernet0.virtualDev = "e1000"

---

### 更换make版本

1. Install the required packages (`gcc`, `make` and such).

2. Open up a shell (if you're using the GUI, a terminal window).

3. Type the following commands (or something equivalent, e.g. you can use `curl` instead of `wget`):

   ```
   cd /tmp
   wget http://ftp.gnu.org/gnu/make/make-3.81.tar.gz
   tar xvf make-4.1.tar.gz
   cd make-4.1/
   ./configure
   make
   sudo make install
   rm -rf make-4.1.tar.gz make-4.1
   ```

Now, `make 4.1` is in `/usr/local/bin/make`.

You can make it your default `make` by prefixing `/usr/local/bin` to your `$PATH` variable in your shell startup file; for instance, in `.profile` or `.bashrc` if you use the `bash` shell.

`export PATH="${PATH}:/some/place/bin"`

Don't try to install a self-compiled `make` (or anything else that doesn't come from the distribution's package manager) into `/bin` or `/usr/bin`; doing that will confuse your package manager.

把gmake链接到这个新的make   `ln -s /usr/local/bin/make /usr/bin/gmake`

---

### 关机

shutdown -h now

---

### SUSE 使SSH通过防火墙

```
安装完suse10后发现系统中默认会添加很多iptables，同时suse默认是开启firewall的，这个和rhel还有点区别。用SecureCRT连入虚拟机中的suse，无法进行ssh连接，于是发现suse firewall中没有允许ssh的服务，遂可以这样设置：
1.使用终端输入yast2: suse-linux:~ # yast2 
2.选择“安全与用户”（Security and Users）选项: 
3.选择“防火墙” （Firewall）
4.选择“Allowed Services” 5.在Allowed Services for Selected Zone中选择“External Zone” 
6.在Service to Allow中选择“SSH”
7.然后点击“Add”，接着点击“Next”进行保存。 
```

命令行界面可以编辑文件，估计是之前自己没有设置好文件的参数。

---

### Centos 5 源 扩展源

http://vault.centos.org

例如：baseurl=http://vault.centos.org/5.0/os/$basearch/

http://archives.fedoraproject.org/pub/archive/epel/

rpm -ivh http://archives.fedoraproject.org/pub/archive/epel/5/x86_64/epel-release-5-4.noarch.rpm

---

### 批量更改时间戳

```
find ./* -exec touch {} \; 
```

---

### 列出当前目录下的所有文件（包括隐藏文件）的绝对路径， 对目录不做递归

find  $PWD -maxdepth 1  | xargs ls -ld

### 递归列出当前目录下的所有文件（包括隐藏文件）的绝对路径

find  $PWD | xargs ls -ld

### 统计文件夹下文件的个数，包括子文件夹里的

ls -lR|grep "^-"|wc -l

---

### include_next<> 解释

include_next <filename.h>

意思就是include位于搜索路径位于当前文件之后的文件filename.h

作用是这样的，就是你想用自己的函数代替其他库函数，但是
1. 不想修改源代码，
2. 不能修改原来的头文件
  这时就可以用#include_next了。

---

### git clone 某个分支的代码

```
git branch -r #查看远程分支
```

或者

```
git branch -a #查看所有分支
```

然后

```
git checkout origin/1.16  #这里后面的是举例
```

即可

---

### 查看文件夹占用空间

`du -sh /your/dic`

---

### 重定向到文件中

以make为例 : `make 1> tmp.log 2>&1`

---

### 获取文件名和后缀名

```
代码：
file=”thisfile.txt”
echo “filename: ${file%.*}”
echo “extension: ${file##*.}”
输出：
filename: thisfile
extension: txt
```

